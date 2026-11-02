param([Parameter(Mandatory=$true)][string]$Setup)
$ErrorActionPreference = 'Stop'
$project = [IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot))
$target = Join-Path $project ('work\install-test-' + [Guid]::NewGuid().ToString('N'))
if (-not [IO.Path]::GetFullPath($target).StartsWith($project + '\work\', [StringComparison]::OrdinalIgnoreCase)) { throw 'Diretório de teste inválido.' }
$checks = 0
function Assert-True($Condition, $Message) { $script:checks++; if (-not $Condition) { throw $Message } }
$log = Join-Path $project 'work\install-test.log'
$setupPath = (Resolve-Path -LiteralPath $Setup).Path
# Only the specially compiled TestInstall executable may be used here.
if ((Split-Path -Leaf $setupPath) -ne 'CoroaQuebrada-Setup-Test.exe') { throw 'Use o instalador com AppId exclusivo de teste.' }
try {
$process = Start-Process -FilePath $setupPath -ArgumentList @('/VERYSILENT','/SUPPRESSMSGBOXES','/NORESTART','/NOICONS',('/DIR="' + $target + '"'),('/LOG="' + $log + '"')) -WindowStyle Hidden -PassThru -Wait
Assert-True ($process.ExitCode -eq 0) 'Instalação silenciosa falhou'
$exe = Join-Path $target 'CoroaQuebrada.exe'
Assert-True (Test-Path -LiteralPath $exe) 'Jogo não foi instalado'
Assert-True (Test-Path -LiteralPath (Join-Path $target 'Atualizar.ps1')) 'Aplicador não foi instalado'
Assert-True (Test-Path -LiteralPath (Join-Path $target 'unins000.exe')) 'Desinstalador não foi instalado'
$gameProcess = Start-Process -FilePath $exe -ArgumentList '--headless','--quit-after','5' -WindowStyle Hidden -PassThru -Wait
Assert-True ($gameProcess.ExitCode -eq 0) 'Jogo instalado não iniciou'
Set-Content -LiteralPath (Join-Path $target 'sentinela-partida.txt') -Value 'preservar'
$version = [regex]::Match((Get-Content -LiteralPath (Join-Path $project 'project.godot') -Raw), 'config/version="(\d+\.\d+\.\d+)"').Groups[1].Value
if (-not $version) { throw 'Versão do projeto não encontrada.' }
$zip = Join-Path $project "outputs\CoroaQuebrada-v$version-Windows.zip"
$hash = (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash
& powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File (Join-Path $target 'Atualizar.ps1') -InstallDir $target -Package $zip -ExpectedHash $hash -ParentId 0 -Version $version -NoRestart
Assert-True ($LASTEXITCODE -eq 0) 'Aplicação do pacote real falhou'
Assert-True ((Get-FileHash -LiteralPath $exe -Algorithm SHA256).Hash -eq (Get-FileHash -LiteralPath (Join-Path $project 'outputs\CoroaQuebrada.exe') -Algorithm SHA256).Hash) 'Binário instalado difere do pacote real'
$gameProcess = Start-Process -FilePath $exe -ArgumentList '--headless','--quit-after','5','--','--resume-save' -WindowStyle Hidden -PassThru -Wait
Assert-True ($gameProcess.ExitCode -eq 0) 'Jogo atualizado não reiniciou com argumento de retomada'
} finally {
    if (Test-Path -LiteralPath (Join-Path $target 'unins000.exe')) {
        $process = Start-Process -FilePath (Join-Path $target 'unins000.exe') -ArgumentList '/VERYSILENT','/SUPPRESSMSGBOXES','/NORESTART' -WindowStyle Hidden -PassThru -Wait
        Assert-True ($process.ExitCode -eq 0) 'Desinstalação falhou'
    }
}
Assert-True (-not (Test-Path -LiteralPath $exe)) 'Desinstalador deixou o executável'
Assert-True ((Get-Content -LiteralPath (Join-Path $target 'sentinela-partida.txt') -Raw).Trim() -eq 'preservar') 'Desinstalação removeu arquivo não gerenciado'
Write-Output "INSTALAÇÃO: $checks verificações, 0 falhas"
Write-Output "Evidências: $target"

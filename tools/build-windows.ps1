param(
    [Parameter(Mandatory=$true)][string]$Godot,
    [string]$ISCC = 'C:\Program Files (x86)\Inno Setup 6\ISCC.exe'
)
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path -Parent $PSScriptRoot)
foreach ($test in @('test_kingdom','test_politics','test_ui','test_updater','test_map','test_atlas')) {
    & $Godot --headless --path . --script "tests/$test.gd"
    if ($LASTEXITCODE -ne 0) { throw "Teste falhou: $test" }
}
& powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File tests/test_update_windows.ps1
if ($LASTEXITCODE -ne 0) { throw 'Teste do aplicador Windows falhou.' }
& node --test tests/test_azgaar.mjs tests/test_azgaar_real.mjs
if ($LASTEXITCODE -ne 0) { throw 'Importador Azgaar falhou.' }
$version = [regex]::Match((Get-Content -LiteralPath project.godot -Raw), 'config/version="(\d+\.\d+\.\d+)"').Groups[1].Value
if (-not $version) { throw 'Versão não encontrada em project.godot.' }
New-Item -ItemType Directory -Force outputs | Out-Null
& $Godot --headless --path . --export-release 'Windows Desktop' outputs/CoroaQuebrada.exe
if ($LASTEXITCODE -ne 0) { throw 'Exportação falhou.' }
$gameProcess = Start-Process -FilePath (Join-Path (Get-Location) 'outputs/CoroaQuebrada.exe') -ArgumentList '--headless','--quit-after','5','--','--verify-atlas' -WindowStyle Hidden -PassThru -Wait
if ($gameProcess.ExitCode -ne 0) { throw 'Executável não iniciou.' }
Copy-Item -LiteralPath installer/Atualizar.ps1 -Destination outputs/Atualizar.ps1 -Force
Copy-Item -LiteralPath THIRD_PARTY_NOTICES.md -Destination outputs/THIRD_PARTY_NOTICES.md -Force
Copy-Item -LiteralPath installer/COMO_JOGAR.txt -Destination outputs/COMO_JOGAR.txt -Force
$zipPath = "outputs/CoroaQuebrada-v$version-Windows.zip"
Compress-Archive -LiteralPath outputs/CoroaQuebrada.exe,outputs/Atualizar.ps1,outputs/COMO_JOGAR.txt,outputs/THIRD_PARTY_NOTICES.md -DestinationPath $zipPath -Force
& $ISCC /Q "/DAppVersion=$version" installer/setup.iss
if ($LASTEXITCODE -ne 0) { throw 'Compilação do instalador falhou.' }
$lines = foreach ($path in @($zipPath, "outputs/CoroaQuebrada-Setup-$version.exe")) {
    ((Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLower() + '  ' + (Split-Path -Leaf $path))
}
Set-Content -LiteralPath outputs/SHA256SUMS.txt -Value $lines -Encoding ascii
Write-Output "Instalador e pacote de atualização $version prontos em outputs."

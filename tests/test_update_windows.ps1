$ErrorActionPreference = 'Stop'
$project = Split-Path -Parent $PSScriptRoot
$testRoot = Join-Path $project ('work\update-tests-' + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $testRoot | Out-Null
$checks = 0
function Assert-True($Condition, $Message) {
    $script:checks++
    if (-not $Condition) { throw $Message }
}
function New-Case($Name) {
    $dir = Join-Path $testRoot $Name
    New-Item -ItemType Directory -Path $dir | Out-Null
    Copy-Item -LiteralPath (Join-Path $project 'installer\Atualizar.ps1') -Destination $dir
    [IO.File]::WriteAllBytes((Join-Path $dir 'CoroaQuebrada.exe'), [byte[]](77,90) + (New-Object byte[] 100))
    Set-Content -LiteralPath (Join-Path $dir 'COMO_JOGAR.txt') -Value 'old'
    Set-Content -LiteralPath (Join-Path $dir 'THIRD_PARTY_NOTICES.md') -Value 'old'
    return $dir
}
function Run-Update($Dir, $Zip, $Hash) {
    & powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File (Join-Path $Dir 'Atualizar.ps1') -InstallDir $Dir -Package $Zip -ExpectedHash $Hash -ParentId 0 -Version '0.3.0' -NoRestart
    return $LASTEXITCODE
}
$source = Join-Path $testRoot 'source'
New-Item -ItemType Directory -Path $source | Out-Null
Copy-Item -LiteralPath (Join-Path $project 'installer\Atualizar.ps1') -Destination $source
[IO.File]::WriteAllBytes((Join-Path $source 'CoroaQuebrada.exe'), [byte[]](77,90) + (New-Object byte[] 200))
Set-Content -LiteralPath (Join-Path $source 'COMO_JOGAR.txt') -Value 'new'
Set-Content -LiteralPath (Join-Path $source 'THIRD_PARTY_NOTICES.md') -Value 'new'
$zip = Join-Path $testRoot 'update.zip'
Compress-Archive -Path (Join-Path $source '*') -DestinationPath $zip
$hash = (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash
$dir = New-Case 'success'
Set-Content -LiteralPath (Join-Path $dir 'reinado.json') -Value 'sentinel-save'
Assert-True ((Run-Update $dir $zip $hash) -eq 0) 'Atualização válida deve concluir'
Assert-True ((Get-Item -LiteralPath (Join-Path $dir 'CoroaQuebrada.exe')).Length -eq 202) 'Executável substituído'
Assert-True ((Get-Content -LiteralPath (Join-Path $dir 'COMO_JOGAR.txt') -Raw).Trim() -eq 'new') 'Conteúdo atualizado'
Assert-True ((Get-Content -LiteralPath (Join-Path $dir 'reinado.json') -Raw).Trim() -eq 'sentinel-save') 'Save não pode ser tocado'
Assert-True (@(Get-ChildItem -LiteralPath $dir -Directory -Filter '.update-*').Count -eq 0) 'Área temporária limpa após sucesso'
$dir = New-Case 'wrong-hash'
Assert-True ((Run-Update $dir $zip ('0' * 64)) -ne 0) 'Hash inválido deve bloquear instalação'
Assert-True ((Get-Item -LiteralPath (Join-Path $dir 'CoroaQuebrada.exe')).Length -eq 102) 'Hash inválido preserva executável'
$dir = New-Case 'locked-file'
$locked = [IO.File]::Open((Join-Path $dir 'COMO_JOGAR.txt'), 'Open', 'Read', 'None')
try {
    Assert-True ((Run-Update $dir $zip $hash) -ne 0) 'Arquivo bloqueado força falha'
    Assert-True ((Get-Item -LiteralPath (Join-Path $dir 'CoroaQuebrada.exe')).Length -eq 102) 'Falha durante troca restaura executável anterior'
} finally { $locked.Dispose() }
Assert-True ((Get-Content -LiteralPath (Join-Path $dir 'COMO_JOGAR.txt') -Raw).Trim() -eq 'old') 'Arquivo bloqueado permaneceu intacto'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$badZip = Join-Path $testRoot 'traversal.zip'
$archive = [IO.Compression.ZipFile]::Open($badZip, 'Create')
try {
    foreach ($name in @('CoroaQuebrada.exe','Atualizar.ps1','COMO_JOGAR.txt','../outside.txt')) {
        $entry = $archive.CreateEntry($name)
        $writer = New-Object IO.StreamWriter($entry.Open())
        $writer.Write('bad')
        $writer.Dispose()
    }
} finally { $archive.Dispose() }
$dir = New-Case 'traversal'
Assert-True ((Run-Update $dir $badZip (Get-FileHash -LiteralPath $badZip -Algorithm SHA256).Hash) -ne 0) 'Pacote com caminho externo é recusado'
Assert-True (-not (Test-Path -LiteralPath (Join-Path $testRoot 'outside.txt'))) 'Nenhum arquivo fora da instalação é criado'
Assert-True ((Get-Item -LiteralPath (Join-Path $dir 'CoroaQuebrada.exe')).Length -eq 102) 'Pacote inesperado preserva versão anterior'
Write-Output "WINDOWS: $checks verificações, 0 falhas"
Write-Output "Evidências: $testRoot"
# Expected failure cases leave a native process exit code of 1. The suite itself passed.
exit 0

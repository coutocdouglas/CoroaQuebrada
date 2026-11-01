param(
    [Parameter(Mandatory=$true)][string]$InstallDir,
    [Parameter(Mandatory=$true)][string]$Package,
    [Parameter(Mandatory=$true)][ValidatePattern('^[a-fA-F0-9]{64}$')][string]$ExpectedHash,
    [Parameter(Mandatory=$true)][int]$ParentId,
    [Parameter(Mandatory=$true)][ValidatePattern('^\d+\.\d+\.\d+$')][string]$Version,
    [switch]$NoRestart
)
$ErrorActionPreference = 'Stop'
$install = [IO.Path]::GetFullPath($InstallDir).TrimEnd('\')
$scriptDir = [IO.Path]::GetFullPath($PSScriptRoot).TrimEnd('\')
if ($install -ne $scriptDir) { throw 'O atualizador deve estar na pasta do jogo.' }
$gamePath = Join-Path $install 'CoroaQuebrada.exe'
if (-not (Test-Path -LiteralPath $gamePath -PathType Leaf)) { throw 'Jogo não encontrado.' }
$lock = $null
$stage = Join-Path $install ('.update-' + [Guid]::NewGuid().ToString('N'))
$backup = Join-Path $stage 'backup'
$changed = @()
$canCleanup = $true
$files = @('CoroaQuebrada.exe','Atualizar.ps1','COMO_JOGAR.txt','THIRD_PARTY_NOTICES.md')
$logPath = Join-Path $install 'atualizacao.log'
try {
    $lock = [IO.File]::Open((Join-Path $install '.update.lock'), 'OpenOrCreate', 'ReadWrite', 'None')
    $packagePath = [IO.Path]::GetFullPath($Package)
    if ((Get-FileHash -LiteralPath $packagePath -Algorithm SHA256).Hash -ne $ExpectedHash) { throw 'A verificação SHA-256 falhou.' }
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [IO.Directory]::CreateDirectory($stage) | Out-Null
    [IO.Directory]::CreateDirectory($backup) | Out-Null
    $archive = [IO.Compression.ZipFile]::OpenRead($packagePath)
    try {
        # Exact allow-list prevents traversal, scripts outside the install, and duplicate entries.
        if ($archive.Entries.Count -ne $files.Count) { throw 'Conteúdo inesperado no pacote.' }
        foreach ($name in $files) {
            $entries = @($archive.Entries | Where-Object { $_.FullName -ceq $name })
            if ($entries.Count -ne 1 -or $entries[0].Length -gt 536870912) { throw "Arquivo inválido: $name" }
            [IO.Compression.ZipFileExtensions]::ExtractToFile($entries[0], (Join-Path $stage $name), $false)
        }
    } finally { $archive.Dispose() }
    $bytes = [IO.File]::ReadAllBytes((Join-Path $stage 'CoroaQuebrada.exe'))
    if ($bytes.Length -lt 64 -or $bytes[0] -ne 77 -or $bytes[1] -ne 90) { throw 'Executável inválido.' }
    $bytes = $null
    if ($ParentId -gt 0) {
        $parent = Get-Process -Id $ParentId -ErrorAction SilentlyContinue
        if ($parent -and -not $parent.WaitForExit(60000)) { throw 'O jogo ainda está aberto. Feche-o e tente novamente.' }
    }
    foreach ($name in $files) {
        $target = Join-Path $install $name
        if (Test-Path -LiteralPath $target) {
            [IO.File]::Replace((Join-Path $stage $name), $target, (Join-Path $backup $name))
        } else {
            [IO.File]::Move((Join-Path $stage $name), $target)
        }
        $changed += $name
    }
    Set-Content -LiteralPath (Join-Path $install 'versao.txt') -Value $Version -Encoding UTF8
    $uninstallKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\{756F69A7-0C6E-4CBC-9F12-48F51838DDC3}_is1'
    if (Test-Path -LiteralPath $uninstallKey) {
        $registered = Get-ItemProperty -LiteralPath $uninstallKey
        if ($registered.InstallLocation -and [IO.Path]::GetFullPath($registered.InstallLocation).TrimEnd('\') -eq $install) {
            Set-ItemProperty -LiteralPath $uninstallKey -Name DisplayVersion -Value $Version
        }
    }
    Set-Content -LiteralPath $logPath -Value ("Atualização concluída: " + $Version) -Encoding UTF8
} catch {
    $reason = $_.Exception.Message
    $canCleanup = $false
    try {
        foreach ($name in $changed) {
            $oldFile = Join-Path $backup $name
            if (Test-Path -LiteralPath $oldFile) {
                Copy-Item -LiteralPath $oldFile -Destination (Join-Path $install $name) -Force
            } else {
                Remove-Item -LiteralPath (Join-Path $install $name) -Force
            }
        }
        $canCleanup = $true
    } catch {
        $reason += ' A restauração automática ficou incompleta; cópias preservadas em ' + $backup
    }
    Set-Content -LiteralPath $logPath -Value ("Atualização não aplicada: " + $reason) -Encoding UTF8
    if (-not $NoRestart) {
        Add-Type -AssemblyName System.Windows.Forms
        [Windows.Forms.MessageBox]::Show("Não foi possível concluir a atualização.`n$reason`nConsulte atualizacao.log na pasta do programa.", 'Coroa Quebrada') | Out-Null
    }
    exit 1
} finally {
    if ($lock) { $lock.Dispose() }
    # Delete only the verified, unique staging directory immediately under this installation.
    $resolvedStage = [IO.Path]::GetFullPath($stage)
    if ($canCleanup -and (Split-Path -Parent $resolvedStage) -eq $install -and (Split-Path -Leaf $resolvedStage) -match '^\.update-[a-f0-9]{32}$' -and (Test-Path -LiteralPath $resolvedStage)) {
        Remove-Item -LiteralPath $resolvedStage -Recurse -Force
    }
}
if (-not $NoRestart) {
    # The game is the visible application requested by the player, not a background helper.
    Start-Process -FilePath $gamePath -ArgumentList '--','--resume-save' -WorkingDirectory $install
}

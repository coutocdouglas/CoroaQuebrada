param([Parameter(Mandatory=$true)][ValidatePattern('^\d+\.\d+\.\d+$')][string]$Version)
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path -Parent $PSScriptRoot)
$sha = (git rev-parse HEAD).Trim()
if (git status --porcelain) { throw 'Registre as alterações antes de publicar.' }
git push
if ($LASTEXITCODE -ne 0) { throw 'Envio ao GitHub falhou.' }
$api = 'https://api.github.com/repos/coutocdouglas/CoroaQuebrada'
$runs = Invoke-RestMethod -Uri "$api/actions/runs?per_page=20"
$run = $runs.workflow_runs | Where-Object { $_.head_sha -eq $sha -and $_.event -eq 'push' } | Select-Object -First 1
if (-not $run -or $run.conclusion -ne 'success') { throw 'Aguarde a verificação automática do commit terminar com sucesso antes de publicar.' }
$credentialLines = @("protocol=https", "host=github.com", "username=coutocdouglas", "") -join "`n" | git credential fill
if ($LASTEXITCODE -ne 0) { throw 'Autenticação Git indisponível.' }
$passwordLine = $credentialLines | Where-Object { $_.StartsWith('password=') } | Select-Object -First 1
if (-not $passwordLine) { throw 'Credencial não encontrada.' }
$headers = @{ Authorization = ('Bearer ' + $passwordLine.Substring(9)); Accept = 'application/vnd.github+json' }
$body = Get-Content -LiteralPath "docs/releases/v$Version.md" -Raw -Encoding utf8
$payload = @{ tag_name = "v$Version"; target_commitish = $sha; name = "v$Version — Coroa Quebrada"; draft = $true; prerelease = $true; body = $body.ToString() } | ConvertTo-Json
$release = Invoke-RestMethod -Method Post -Uri "$api/releases" -Headers $headers -ContentType 'application/json; charset=utf-8' -Body ([Text.Encoding]::UTF8.GetBytes($payload))
$upload = $release.upload_url -replace '\{.*$', ''
foreach ($name in @("CoroaQuebrada-v$Version-Windows.zip", "CoroaQuebrada-Setup-$Version.exe", 'SHA256SUMS.txt')) {
    $path = Join-Path (Get-Location) "outputs/$name"
    $mime = if ($name.EndsWith('.zip')) { 'application/zip' } else { 'application/octet-stream' }
    $asset = Invoke-RestMethod -Method Post -Uri ($upload + '?name=' + $name) -Headers $headers -ContentType $mime -InFile $path -TimeoutSec 180
    $expected = 'sha256:' + (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLower()
    if ($asset.state -ne 'uploaded' -or $asset.size -ne (Get-Item -LiteralPath $path).Length -or $asset.digest -ne $expected) {
        throw 'Upload incompleto ou hash divergente. A release foi mantida como rascunho.'
    }
}
$release = Invoke-RestMethod -Method Patch -Uri "$api/releases/$($release.id)" -Headers $headers -ContentType 'application/json' -Body '{"draft":false}'
Write-Output ('PUBLICADO=' + $release.html_url)
$credentialLines = $null
$passwordLine = $null
$headers = $null

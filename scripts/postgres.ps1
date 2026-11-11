$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$data = Join-Path $root ".local\postgres\data"
$log = Join-Path $root ".local\postgres\server.log"
$pgCtl = "C:\Program Files\PostgreSQL\18\bin\pg_ctl.exe"

if (-not (Test-Path $data)) {
    Write-Error "PostgreSQL data directory is missing. It is created during environment setup at .local/postgres/data."
}

& $pgCtl -D $data status | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Output "PostgreSQL already running on 127.0.0.1:5434"
    exit 0
}

& $pgCtl -D $data -l $log -o "-p 5434 -h 127.0.0.1" start
Write-Output "PostgreSQL started on 127.0.0.1:5434"

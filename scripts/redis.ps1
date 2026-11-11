$ErrorActionPreference = "Stop"
$server = "$env:LOCALAPPDATA\redis\Redis-8.10.2-Windows-x64-msys2\redis-server.exe"
$cli = "$env:LOCALAPPDATA\redis\Redis-8.10.2-Windows-x64-msys2\redis-cli.exe"

if (-not (Test-Path $server)) {
    Write-Error "Redis is not installed at $server"
}

& $cli -h 127.0.0.1 -p 6379 ping 2>$null | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Output "Redis already running on 127.0.0.1:6379"
    exit 0
}

Start-Process -FilePath $server -ArgumentList @(
    "--bind", "127.0.0.1",
    "--port", "6379",
    "--protected-mode", "yes",
    "--dir", "$env:LOCALAPPDATA\redis",
    "--logfile", "$env:LOCALAPPDATA\redis\redis.log"
) -WindowStyle Hidden

Start-Sleep -Seconds 1
& $cli -h 127.0.0.1 -p 6379 ping

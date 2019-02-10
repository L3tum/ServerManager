$ErrorActionPreference = 'SilentlyContinue';
docker kill servermanagertest
docker rm -f servermanagertest

$ErrorActionPreference = 'Stop';
Write-Host Starting container
docker run --name servermanagertest -d servermanager
Start-Sleep 10

docker logs servermanagertest

$ErrorActionPreference = 'SilentlyContinue';
docker kill servermanagertest
docker rm -f servermanagertest
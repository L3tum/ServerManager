$ErrorActionPreference = 'SilentlyContinue';
docker kill riasetest
docker rm -f riasetest

$ErrorActionPreference = 'Stop';
Write-Host Starting container
docker run --name riasetest -d riase:windows-amd64
Start-Sleep 10

docker logs riasetest

$ErrorActionPreference = 'SilentlyContinue';
docker kill riasetest
docker rm -f riasetest
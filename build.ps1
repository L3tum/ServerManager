$ErrorActionPreference = 'Stop';
Write-Host Starting build

If ($isWindows) {
	docker build --pull -t riase:linux-arm -f Dockerfile.arm32v7 .
	docker build --pull -t riase:linux-amd64 -f Dockerfile.alpine .
	docker build --pull -t riase:windows-amd64 -f Dockerfile.1809 .
	docker build --pull -t riase:windows-arm -f Dockerfile.1809-arm32v7 .
} Else{
	docker build -t riase:linux-arm -f Dockerfile.arm32v7 .
	docker build -t riase:linux-amd64 -f Dockerfile.alpine .
	docker build -t riase:windows-amd64 -f Dockerfile.1809 .
	docker build -t riase:windows-arm -f Dockerfile.1809-arm32v7 .
}

docker images
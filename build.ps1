$ErrorActionPreference = 'Stop';
Write-Host Starting build

if ($isWindows) {
	if($env:ARCH -eq "amd64") {
		docker build -t servermanager -f Dockerfile.1703 .
	}
} else {
	if($env:ARCH -eq "arm") {
		docker build -t servermanager -f Dockerfile.arm32v7 .
	} elseif($env:ARCH -eq "arm64") {
		docker build -t servermanager -f Dockerfile.arm64 .
	} else {
		docker build -t servermanager -f Dockerfile.alpine .
	}
}

docker images
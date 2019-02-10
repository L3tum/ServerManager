$ErrorActionPreference = 'Stop';
Write-Host Starting build

if ($isWindows) {
	if($env:ARCH -eq "amd64") {
		docker build -t riase -f Dockerfile.1703 .
	}
} else {
	if($env:ARCH -eq "arm") {
		docker build -t riase -f Dockerfile.arm32v7 .
	} else {
		docker build -t riase -f Dockerfile.alpine .
	}
}

docker images
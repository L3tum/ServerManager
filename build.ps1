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
		
		# Build as-is
		
		Write-Host "Building Project"
		
		dotnet publish ServerManager -c Release --force -f netcoreapp2.1 -v minimal -o /home/appveyor/projects/servermanager/ServerManager/bin/Release/netcoreapp2.1/publish
		
		# Collect artifacts
		
		Write-Host "Collecting Artifacts"
		
		Compress-Archive -Path /home/appveyor/projects/servermanager/ServerManager/bin/Release/netcoreapp2.1/publish -DestinationPath /home/appveyor/projects/servermanager/ServerManager/bin/Release/netcoreapp2.1/ServerManager.zip
		Push-AppveyorArtifact /home/appveyor/projects/servermanager/ServerManager/bin/Release/netcoreapp2.1/ServerManager.zip -DeploymentName ServerManager.zip
		
		$env:DEPLOY_GITHUB = true
	}
}

docker images
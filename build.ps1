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
		
		# Build as-is (we do that on the Linux AMD64 Build and not Windows because the Windows build takes long enough)
		
		Write-Host "Building Project"
		
		dotnet publish ServerManager -c Release --force -v minimal -o /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager
		dotnet publish ServerManager -c Release -r win-x64 --self-contained false -o /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-win-x64
		dotnet publish ServerManager -c Release -r win-x86 --self-contained false -o /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-win-x86
		dotnet publish ServerManager -c Release -r win10-arm --self-contained false -o /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-win-arm
		dotnet publish ServerManager -c Release -r win10-arm64 --self-contained false -o /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-win-arm64
		dotnet publish ServerManager -c Release -r linux-x64 --self-contained false -o /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-linux-x64
		dotnet publish ServerManager -c Release -r debian-x64 --self-contained false -o /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-debian-x64
		dotnet publish ServerManager -c Release -r ubuntu-x64 --self-contained false -o /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-ubuntu-x64
		dotnet publish ServerManager -c Release -r osx-x64 --self-contained false -o /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-osx-x64
		
		Copy-Item /home/appveyor/projects/servermanager/README.md /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager/README.md
		Copy-Item /home/appveyor/projects/servermanager/README.md /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-win-x64/README.md
		Copy-Item /home/appveyor/projects/servermanager/README.md /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-win-x86/README.md
		Copy-Item /home/appveyor/projects/servermanager/README.md /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-win-arm/README.md
		Copy-Item /home/appveyor/projects/servermanager/README.md /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-win-arm64/README.md
		Copy-Item /home/appveyor/projects/servermanager/README.md /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-linux-x64/README.md
		Copy-Item /home/appveyor/projects/servermanager/README.md /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-debian-x64/README.md
		Copy-Item /home/appveyor/projects/servermanager/README.md /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-ubuntu-x64/README.md
		Copy-Item /home/appveyor/projects/servermanager/README.md /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-osx-x64/README.md
		
		Copy-Item /home/appveyor/projects/servermanager/LICENSE /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager/LICENSE
		Copy-Item /home/appveyor/projects/servermanager/LICENSE /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-win-x64/LICENSE
		Copy-Item /home/appveyor/projects/servermanager/LICENSE /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-win-x86/LICENSE
		Copy-Item /home/appveyor/projects/servermanager/LICENSE /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-win-arm/LICENSE
		Copy-Item /home/appveyor/projects/servermanager/LICENSE /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-win-arm64/LICENSE
		Copy-Item /home/appveyor/projects/servermanager/LICENSE /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-linux-x64/LICENSE
		Copy-Item /home/appveyor/projects/servermanager/LICENSE /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-debian-x64/LICENSE
		Copy-Item /home/appveyor/projects/servermanager/LICENSE /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-ubuntu-x64/LICENSE
		Copy-Item /home/appveyor/projects/servermanager/LICENSE /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-osx-x64/LICENSE
		
		# Collect artifacts
		
		Write-Host "Collecting Artifacts"
		
		Compress-Archive -Path /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager -DestinationPath /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager.zip
		Compress-Archive -Path /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-win-x64 -DestinationPath /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-win-x64.zip
		Compress-Archive -Path /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-win-x86 -DestinationPath /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-win-x86.zip
		Compress-Archive -Path /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-win-arm -DestinationPath /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-win-arm.zip
		Compress-Archive -Path /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-win-arm64 -DestinationPath /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-win-arm64.zip
		Compress-Archive -Path /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-linux-x64 -DestinationPath /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-linux-x64.zip
		Compress-Archive -Path /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-debian-x64 -DestinationPath /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-debian-x64.zip
		Compress-Archive -Path /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-ubuntu-x64 -DestinationPath /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-ubuntu-x64.zip
		Compress-Archive -Path /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-osx-x64 -DestinationPath /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-osx-x64.zip
		
		Push-AppveyorArtifact /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager.zip -DeploymentName ServerManager.zip
		Push-AppveyorArtifact /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-win-x64.zip -DeploymentName ServerManager-win-x64.zip
		Push-AppveyorArtifact /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-win-x86.zip -DeploymentName ServerManager-win-x86.zip
		Push-AppveyorArtifact /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-win-arm.zip -DeploymentName ServerManager-win-arm.zip
		Push-AppveyorArtifact /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-win-arm64.zip -DeploymentName ServerManager-win-arm64.zip
		Push-AppveyorArtifact /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-linux-x64.zip -DeploymentName ServerManager-linux-x64.zip
		Push-AppveyorArtifact /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-debian-x64.zip -DeploymentName ServerManager-debian-x64.zip
		Push-AppveyorArtifact /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-ubuntu-x64.zip -DeploymentName ServerManager-ubuntu-x64.zip
		Push-AppveyorArtifact /home/appveyor/projects/servermanager/ServerManager/bin/Release/ServerManager-osx-x64.zip -DeploymentName ServerManager-osx-x64.zip
	}
}

docker images
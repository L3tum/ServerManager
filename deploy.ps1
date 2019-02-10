$ErrorActionPreference = 'Stop';

if (! (Test-Path Env:\APPVEYOR_REPO_TAG_NAME)) {
  Write-Host "No version tag detected. Skip publishing."
  exit 0
}

$image = "l3tum/servermanager"

Write-Host Starting deploy
if (!(Test-Path ~/.docker)) { mkdir ~/.docker }
# "$env:DOCKER_PASS" | docker login --username "$env:DOCKER_USER" --password-stdin
# docker login with the old config.json style that is needed for manifest-tool
$auth =[System.Text.Encoding]::UTF8.GetBytes("$($env:DOCKER_USER):$($env:DOCKER_PASS)")
$auth64 = [Convert]::ToBase64String($auth)
@"
{
  "auths": {
    "https://index.docker.io/v1/": {
      "auth": "$auth64"
    }
  },
  "experimental": "enabled"
}
"@ | Out-File -Encoding Ascii ~/.docker/config.json

$os = If($isWindows){"windows"} Else {"linux"}

docker tag servermanager "$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME"
docker push "$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME"

if ($isWindows) {
	if($env:ARCH -eq "amd64") {
		# Windows
		Write-Host "Rebasing image to produce 1709 variant"
		npm install -g rebase-docker-image
		rebase-docker-image `
		"$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME" `
		-s microsoft/nanoserver:sac2016 `
		-t "$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME-1709" `
		-b microsoft/dotnet:2.1-aspnetcore-runtime-nanoserver-1709 `
		-v
		
		Write-Host "Rebasing image to produce 1803 variant"
		npm install -g rebase-docker-image
		rebase-docker-image `
		"$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME" `
		-s microsoft/nanoserver:sac2016 `
		-t "$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME-1803" `
		-b microsoft/dotnet:2.1-aspnetcore-runtime-nanoserver-1803 `
		-v
		
		Write-Host "Rebasing image to produce 1809 variant"
		npm install -g rebase-docker-image
		rebase-docker-image `
		"$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME" `
		-s microsoft/nanoserver:sac2016 `
		-t "$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME-1809" `
		-b microsoft/dotnet:2.1-aspnetcore-runtime-nanoserver-1809 `
		-v
	}
} else {
	# Last in build matrix, gets to push the manifest
	if($env:ARCH -eq "amd64") {
		docker -D manifest create "$($image):$env:APPVEYOR_REPO_TAG_NAME" `
		"$($image):linux-amd64-$env:APPVEYOR_REPO_TAG_NAME" `
		"$($image):linux-arm-$env:APPVEYOR_REPO_TAG_NAME" `
		"$($image):linux-arm64-$env:APPVEYOR_REPO_TAG_NAME" `
		"$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME" `
		"$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME-1709" `
		"$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME-1803" `
		"$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME-1809"
		docker manifest annotate "$($image):$env:APPVEYOR_REPO_TAG_NAME" "$($image):linux-arm-$env:APPVEYOR_REPO_TAG_NAME" --os linux --arch arm --variant v6
		docker manifest annotate "$($image):$env:APPVEYOR_REPO_TAG_NAME" "$($image):linux-arm64-$env:APPVEYOR_REPO_TAG_NAME" --os linux --arch arm64 --variant v8
		docker manifest push "$($image):$env:APPVEYOR_REPO_TAG_NAME"
		
		Write-Host "Pushing manifest $($image):latest"
		docker -D manifest create "$($image):latest" `
		"$($image):linux-amd64-$env:APPVEYOR_REPO_TAG_NAME" `
		"$($image):linux-arm-$env:APPVEYOR_REPO_TAG_NAME" `
		"$($image):linux-arm64-$env:APPVEYOR_REPO_TAG_NAME" `
		"$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME" `
		"$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME-1709" `
		"$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME-1803" `
		"$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME-1809"
		docker manifest annotate "$($image):$env:APPVEYOR_REPO_TAG_NAME" "$($image):linux-arm-$env:APPVEYOR_REPO_TAG_NAME" --os linux --arch arm --variant v6
		docker manifest annotate "$($image):$env:APPVEYOR_REPO_TAG_NAME" "$($image):linux-arm64-$env:APPVEYOR_REPO_TAG_NAME" --os linux --arch arm64 --variant v8
		docker manifest push "$($image):latest"
		
		Write-Host "Doing git stuff"
		
		# Generate Changelog
		npm i changelog-maker -g
		
		changelog-maker L3tum ServerManager >> /home/appveyor/projects/servermanager/Changelog.md
		
		git config --global credential.helper store
		Add-Content "$HOME\.git-credentials" "https://$($env:GITHUB_TOKEN):x-oauth-basic@github.com`n"
		
		# Push changelog, generate release branch, push it, go back to master
		
		git push
		git checkout -b release-$env:APPVEYOR_REPO_TAG_NAME master
		git push
		git checkout master
		
		# Build as-is
		
		Write-Host "Building Project"
		
		dotnet publish ServerManager -c Release --force --manifest ServerManager/Properties/PublishProfiles/FolderProfile.pubxml -v minimal -o /home/appveyor/projects/servermanager/servermanager/bin/Release/netcoreapp2.1/publish
		
		# Collect artifacts
		
		Write-Host "Collecting Artifacts"
		
		Compress-Archive -Path /home/appveyor/projects/servermanager/servermanager/bin/Release/netcoreapp2.1/publish -DestinationPath /home/appveyor/projects/servermanager/servermanager/bin/Release/netcoreapp2.1/ServerManager.zip
		Push-AppveyorArtifact /home/appveyor/projects/servermanager/servermanager/bin/Release/netcoreapp2.1/ServerManager.zip -DeploymentName ServerManager.zip
		
		# Publish release
		
		Write-Host "Publishing Github Release"
		 
		npm install -g publish-release
		publish-release --token $env:GITHUB_TOKEN --owner L3tum --repo ServerManager --name ServerManager-v$env:APPVEYOR_REPO_TAG_NAME --reuseRelease --assets /home/appveyor/projects/servermanager/servermanager/bin/Release/netcoreapp2.1/ServerManager.zip --notes $(changelog-maker L3tum ServerManager)
	}
}
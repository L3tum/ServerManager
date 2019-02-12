$ErrorActionPreference = 'Stop';
$image = "l3tum/servermanager"
$os = If($isWindows){"windows"} Else {"linux"}


$imageID = docker images -q "$image:$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME"

# Branch is not master, it is a pull request into master (otherwise previous would fail), or image already exists
if (! ($env:APPVEYOR_REPO_BRANCH -eq "master") -Or Test-Path $env:APPVEYOR_PULL_REQUEST_NUMBER -Or $env:APPVEYOR_PULL_REQUEST_NUMBER -Or $imageID) {
  Write-Host "Skip publishing."
  exit 0
}

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
		-b microsoft/dotnet:2.2-aspnetcore-runtime-nanoserver-1709
		
		Write-Host "Rebasing image to produce 1803 variant"
		npm install -g rebase-docker-image
		rebase-docker-image `
		"$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME" `
		-s microsoft/nanoserver:sac2016 `
		-t "$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME-1803" `
		-b microsoft/dotnet:2.2-aspnetcore-runtime-nanoserver-1803
		
		Write-Host "Rebasing image to produce 1809 variant"
		npm install -g rebase-docker-image
		rebase-docker-image `
		"$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME" `
		-s microsoft/nanoserver:sac2016 `
		-t "$($image):$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME-1809" `
		-b microsoft/dotnet:2.2-aspnetcore-runtime-nanoserver-1809
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
		
		#git checkout master
		
		# Generate Changelog
		
		git config --global credential.helper store
		Add-Content "$HOME\.git-credentials" "https://$($env:GITHUB_TOKEN):x-oauth-basic@github.com`n"
		
		#go get -u github.com/git-chglog/git-chglog/cmd/git-chglog
		
		#git-chglog -o /home/appveyor/projects/servermanager/Changelog.md
		
		# Push changelog, generate release branch, push it, go back to master
		
		#git add /home/appveyor/projects/servermanager/Changelog.md
		#git commit -m "Updated Changelog"
		#git push -f origin master
		git checkout -b $env:APPVEYOR_REPO_TAG_NAME master
		git push --set-upstream origin $env:APPVEYOR_REPO_TAG_NAME
	}
}
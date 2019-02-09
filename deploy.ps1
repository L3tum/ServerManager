$ErrorActionPreference = 'Stop';

if (! (Test-Path Env:\APPVEYOR_REPO_TAG_NAME)) {
  Write-Host "No version tag detected. Skip publishing."
  exit 0
}

$image = "l3tum/riase"

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

$os = If ($isWindows) {"windows"} Else {"linux"}
docker tag riase:windows-amd64 "$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME"
docker tag riase:windows-arm "$($image):windows-arm-$env:APPVEYOR_REPO_TAG_NAME"
docker tag riase:linux-amd64 "$($image):linux-amd64-$env:APPVEYOR_REPO_TAG_NAME"
docker tag riase:linux-arm "$($image):linux-arm-$env:APPVEYOR_REPO_TAG_NAME"
docker push "$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME"
docker push "$($image):windows-arm-$env:APPVEYOR_REPO_TAG_NAME"
docker push "$($image):linux-amd64-$env:APPVEYOR_REPO_TAG_NAME"
docker push "$($image):linux-arm-$env:APPVEYOR_REPO_TAG_NAME"


docker -D manifest create "$($image):$env:APPVEYOR_REPO_TAG_NAME" `
  "$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME" `
  "$($image):windows-arm-$env:APPVEYOR_REPO_TAG_NAME" `
  "$($image):linux-amd64-$env:APPVEYOR_REPO_TAG_NAME" `
  "$($image):linux-arm-$env:APPVEYOR_REPO_TAG_NAME"
#docker manifest annotate "$($image):$env:APPVEYOR_REPO_TAG_NAME" "$($image):linux-arm-$env:APPVEYOR_REPO_TAG_NAME" --os linux --arch arm --variant v6
#docker manifest annotate "$($image):$env:APPVEYOR_REPO_TAG_NAME" "$($image):linux-arm64-$env:APPVEYOR_REPO_TAG_NAME" --os linux --arch arm64 --variant v8
docker manifest push "$($image):$env:APPVEYOR_REPO_TAG_NAME"

Write-Host "Pushing manifest $($image):latest"
docker -D manifest create "$($image):latest" `
  "$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME" `
  "$($image):windows-arm-$env:APPVEYOR_REPO_TAG_NAME" `
  "$($image):linux-amd64-$env:APPVEYOR_REPO_TAG_NAME" `
  "$($image):linux-arm-$env:APPVEYOR_REPO_TAG_NAME"
docker manifest push "$($image):latest"
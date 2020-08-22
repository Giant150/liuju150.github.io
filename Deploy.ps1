Write-Host 'Build Starting' -ForegroundColor Yellow
Invoke-Command -ScriptBlock {npm run clean}
Invoke-Command -ScriptBlock {npm run deploy}
Write-Host 'Build Completed' -ForegroundColor Green

Write-Host 'Compress Starting' -ForegroundColor Yellow
$CurDateString=Get-Date -Format "yyyyMMddHHmmss"
$ZIPFileName="Blog"+$CurDateString+".zip"
$CurPath=(Resolve-Path .).Path
$ZIPFilePath=$CurPath+"\"+$ZIPFileName
Compress-Archive -Path ".\public\*" -DestinationPath $ZIPFilePath
Write-Host 'Compress Completed' -ForegroundColor Green

Write-Host 'Deploy Starting' -ForegroundColor Yellow
$User = "WDeployAdmin"
$Password = Read-Host -Prompt "Please enter the server password" -AsSecureString
Write-Host 'Start connecting to the server' -ForegroundColor Yellow
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $Password
$Session = New-PSSession -ComputerName 114.115.162.100 -Credential $Credential
Write-Host 'Successfully connected to the server' -ForegroundColor Green
Write-Host 'Start copying files to the server' -ForegroundColor Yellow
$RemotePath="D:\Publish\"
Copy-Item $ZIPFilePath -Destination $RemotePath -ToSession $Session
Write-Host 'Copy files completed' -ForegroundColor Green
Write-Host 'Start Expand files on the server' -ForegroundColor Yellow
$RemoteDestinationPath=$RemotePath+"Blog\"
$RemoteZipPath=$RemotePath+$ZIPFileName
Invoke-Command -Session $Session -ScriptBlock {param($p) Remove-Item -Path $p -Recurse -Force} -ArgumentList $RemoteDestinationPath
Invoke-Command -Session $Session -ScriptBlock {param($p,$dp) Expand-Archive -Path $p -DestinationPath $dp} -ArgumentList $RemoteZipPath,$RemoteDestinationPath
Write-Host 'Expand Completed' -ForegroundColor Green
Disconnect-PSSession -Session $Session
Remove-Item -Path $ZIPFilePath
Write-Host 'Disconnected from server' -ForegroundColor Yellow
Write-Host 'Deploy Completed' -ForegroundColor Green
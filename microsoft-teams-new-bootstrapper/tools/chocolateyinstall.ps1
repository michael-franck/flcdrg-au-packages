﻿$ErrorActionPreference = 'Stop';
$toolsDir     = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$minimumOsVersion = "10.0.19041" # 20H1
$osVersion = (Get-CimInstance Win32_OperatingSystem).Version
if ([Version] $osVersion -lt [version] $minimumOsVersion) {
  Write-Error "Microsoft Teams New Client requires a minimum of Windows 10 20H1 version $minimumOsVersion. You have $osVersion"
}

$checksum32 = '028B1DF4D837B2676B3F9C18E65116A7AE20AC9EBF32FD0C9A08D66EC2BD1785'

$downloadPath = Join-Path $toolsDir "teamsbootstrapper.exe"

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  softwareName  = 'microsoft-teams-new-bootstrapper*'
  fileType      = 'exe'
  
  url           = "https://statics.teams.cdn.office.net/production-teamsprovision/lkg/teamsbootstrapper.exe"
  checksum      = $checksum32
  checksumType  = 'sha256'
  FileFullPath  = $downloadPath
}

Get-ChocolateyWebFile @packageArgs

# Teams MSIX

$filename = "MSTeams.msix"
$installPath = Join-Path $toolsDir $filename

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  
  # webView2Canary
  url           = "https://statics.teams.microsoft.com/production-windows-x86/24004.1307.2669.7070/MSTeams-x86.msix"
  checksum      = '623647219971370D3E08D703E0A3CE197B978C221E77B108089A2A1F9E28F800'
  checksumType  = 'sha256'
  url64bit      = "https://statics.teams.microsoft.com/production-windows-x64/24004.1307.2669.7070/MSTeams-x64.msix"
  checksum64    = 'ABA78B34B5E0BFD29AED18A86A926427B17127D80457C829C1512534510E7CD2'
  checksumType64= 'sha256'
  fileFullPath  = $installPath
}

Get-ChocolateyWebFile @packageArgs

Write-Host "Installing $downloadPath with $installPath"
& $downloadPath -p -o "$installPath"

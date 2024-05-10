<#
.SYNOPSIS
    Submit file to VirusTotal
#>
function Send-FileToVirusTotal {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$File
    )

    if (-not (Test-Path env:VT_APIKEY))
    {
        Write-Warning "VT_APIKEY not set, skipping submission"
        return
    }

    Write-Host "Submitting file $File to VirusTotal"

    vt.exe scan file $File --apikey $env:VT_APIKEY
}

<#
.SYNOPSIS
    Submit file(s) to VirusTotal
.NOTES
    Call from global:au_AfterUpdate
#>
function VirusTotal_AfterUpdate ($Package)  {
    
    if ($Package.RemoteVersion -ne $Package.NuspecVersion -and $Package.Files) {

        foreach ($file in ($Package.Files | Select-Object -Unique)) {
            Send-FileToVirusTotal $file
        }
    }
}

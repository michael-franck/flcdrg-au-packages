param(
    [string] $name,
    [switch] $readVersionFromInstaller
)

Import-Module chocolatey-au

. ..\_scripts\Submit-VirusTotal.ps1


function global:au_SearchReplace {
    @{
        'tools\chocolateyInstall.ps1' = @{
            "(^[$]url\s*=\s*)(['`"].*['`"])"      = "`$1'$($Latest.URL32)'"
            "(^[$]checksum\s*=\s*)('.*')" = "`$1'$($Latest.Checksum32)'"
        }
    }
}

function global:au_GetLatest {

    try {

        # Make sure the release is at least 2 days old before we make a package for it.
        # That's because Redgate can sometimes release toolbelts multiple times per day.
        # Because installers are released in a yyyy-MM-dd subfolder, previous installers
        # released in the same day are overriden which will cause
        # checksums to mismatch if we generate the chocolatey package too quickly.
        $lastModified = [DateTimeOffset]::UtcNow.AddDays(-2)

        # Redgate's installers are uploaded to https://download.red-gate.com/installers/<name>/<date-released>/<name>.exe
        # and the main https://download.red-gate.com/<name>.exe is just a redirect.
        # so use the url with the date to keep the chocolatey package stable and do away with checksum errors.
        $dateReleased = $lastModified.ToString("yyyy-MM-dd")
        $downloadUrl = "https://download.red-gate.com/installers/$name/$dateReleased/$name.exe"

        $downloadedFile = [IO.Path]::GetTempFileName()

        Write-Verbose "Downloading $downloadUrl"
        try {
            
            $client = new-object System.Net.WebClient
            $client.DownloadFile($downloadUrl, $downloadedFile)
        }
        catch {
            if ($_.Exception -and $_.Exception.InnerException -and $_.Exception.InnerException.Message) {
                $msg = $_.Exception.InnerException.Message
            } else {
                $msg = $_
            }
            Write-Warning "Could not find file $downloadUrl, $msg"
            return 'ignore'
        }

        if ($readVersionFromInstaller.IsPresent) {
            # SqlSearch has strange FileVersion, so use FileVersionRaw as that seems correct
            $version = (get-item $downloadedFile).VersionInfo.FileVersionRaw
        } else {
            # Some of Redgate's installers are bundles of other installers. (The toolbelts and dev bundles)
            # In that case, the version number embedded in the installer is irrelevant.
            # So use the date the installer was released instead.
            $version = $lastModified.ToString("yyyy.MM.dd")
        }
        Write-Verbose "$version"
        $checksum = (Get-FileHash $downloadedFile -Algorithm SHA256).Hash
        Write-Verbose "$checksum"

        Remove-Item $downloadedFile

        $Latest = @{ 
            URL32 = $downloadUrl
            Version = $version
            Checksum32 = $checksum
            LastModified = $lastModified
        }

    } catch {
        Write-Error $_

        $Latest = 'ignore'
    }
     
    return $Latest
}

function global:au_AfterUpdate ($Package)  {
    VirusTotal_AfterUpdate $Package
}

update -ChecksumFor none
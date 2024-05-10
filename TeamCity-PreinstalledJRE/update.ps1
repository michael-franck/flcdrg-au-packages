Import-Module chocolatey-au

. ..\teamcity\update-common.ps1

function global:au_SearchReplace {
    @{
        'tools\chocolateyInstall.ps1' = @{
            "(^[$]version\s*=\s*)('.*')"      = "`$1'$($Latest.Version)'"
        }

        #       <dependency id="teamcity" version="[2019.1]" />
        "$($Latest.PackageName).nuspec" = @{
            "(\<dependency id=`"teamcity`" version=`"\[).*?(\]`" /\>)" = "`${1}$($Latest.Version)`$2"
        }
     }
}

function global:au_GetLatest {
    return Get-TeamCityLatest "2019.1"
}

update -ChecksumFor none
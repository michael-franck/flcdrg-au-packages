Import-Module chocolatey-au

$releases = 'https://www.scootersoftware.com/download'

function global:au_SearchReplace {
    @{
        'tools\chocolateyInstall.ps1' = @{
            "(^\`$version\s*=\s*)('.*')"    = "`$1'$($Latest.Version)'"
            "(^\`$checksum\s*=\s*)('.*')"   = "`$1'$($Latest.Checksum_EN)'"
            "(^\`$checksumde\s*=\s*)('.*')" = "`$1'$($Latest.Checksum_DE)'"
            "(^\`$checksumfr\s*=\s*)('.*')" = "`$1'$($Latest.Checksum_FR)'"
            "(^\`$checksumjp\s*=\s*)('.*')" = "`$1'$($Latest.Checksum_JP)'"
            "(^\`$checksumzh\s*=\s*)('.*')" = "`$1'$($Latest.Checksum_ZH)'"
        }
    }
}

function global:au_GetLatest {
    # 32bit
    $download_page = Invoke-WebRequest -Uri $releases

    #https://www.scootersoftware.com/files/BCompare-4.2.1.22354.exe
    
    $content = $download_page.Content.Trim()

    $content -match "BCompare-(?<version>\d+\.\d+\.\d+\.\d+)\.exe"

    $version = $Matches.version

    $url_en = "https://www.scootersoftware.com/files/BCompare-$($version).exe"

    # https://www.scootersoftware.com/files/BCompare-de-4.2.1.22354.exe
    # https://www.scootersoftware.com/files/BCompare-fr-4.2.1.22354.exe
    # https://www.scootersoftware.com/files/BCompare-jp-4.2.1.22354.exe

    $url_de = "https://www.scootersoftware.com/files/BCompare-de-$($version).exe"
    $url_fr = "https://www.scootersoftware.com/files/BCompare-fr-$($version).exe"
    $url_jp = "https://www.scootersoftware.com/files/BCompare-jp-$($version).exe"
    $url_zh = "https://www.scootersoftware.com/files/BCompare-zh-$($version).exe"
    $Latest = @{ 
        URL_EN = $url_en
        URL_DE = $url_de
        URL_FR = $url_fr
        URL_JP = $url_jp
        URL_ZH = $url_zh
        Version = $version 
    }

    return $Latest
}

function global:au_BeforeUpdate() {
    $Latest.Checksum_EN = Get-RemoteChecksum $Latest.URL_EN
    $Latest.Checksum_DE = Get-RemoteChecksum $Latest.URL_DE
    $Latest.Checksum_FR = Get-RemoteChecksum $Latest.URL_FR
    $Latest.Checksum_JP = Get-RemoteChecksum $Latest.URL_JP
    $Latest.Checksum_ZH = Get-RemoteChecksum $Latest.URL_ZH
}

update -ChecksumFor none
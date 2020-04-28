#Requires -Version 7

$download_webpage = Invoke-WebRequest -Uri "https://www.packer.io/downloads.html"
$download_links = $download_webpage.Links
$packer_releases = Invoke-WebRequest -Uri "https://github.com/hashicorp/packer/releases"
$packer_latest_release_href = $packer_releases.Links | Where-Object { ($_.href -match "releases") -and ( $_.href -match '\d{1}\.?\d?\.?\d' ) -and ( $_.href -notmatch "nightly" ) } | Select-Object -First 1 href
$packer_latest_release = ($packer_latest_release_href.href -split '/' | Select-Object -last  1).Substring(1.)

$packer_bin = Get-ChildItem -Path $PSScriptRoot -Exclude *.ps1, *.zip | Sort-Object | Select-Object -First 1 *
if ($null -ne $packer_bin) {
    if ($($packer_bin.Name) -match "$packer_latest_release") {
        Write-Host "Already have the latest packer."
        return
    }   
}

$os = ""
if ($IsWindows) {
    $os = "windows"
}
foreach ($link in $download_links) {
    if (($link -match "$env:PROCESSOR_ARCHITECTURE") -and ($link -match "$os") -and ($link -match "$packer_latest_release" )) {
        $zip_file = "$PSScriptRoot\packer-$packer_latest_release-$os-$($env:PROCESSOR_ARCHITECTURE.ToLower()).zip"
        Invoke-WebRequest -Uri "$($link.href)" -SslProtocol Tls12 -Method Get -OutFile $zip_file
        Expand-Archive -Path $zip_file -DestinationPath "$PSScriptRoot" -Force
        if ($null -eq $packer_bin) {
            $packer_bin = Get-ChildItem -Path $PSScriptRoot -Exclude *.ps1, *.zip | Sort-Object | Select-Object -Last 1 *
        }
        if (-not(Test-Path -Path "$($packer_bin.Directory)\packer-$packer_latest_release-$os-$($env:PROCESSOR_ARCHITECTURE.ToLower()).$($packer_bin.Extension))")) {
            try {
                Rename-Item -Path $packer_bin.FullName -NewName "packer-$packer_latest_release-$os-$($env:PROCESSOR_ARCHITECTURE.ToLower())$($packer_bin.Extension)" -ErrorAction Stop -Verbose
                Remove-Item -Path $zip_file
            }
            catch {
                $packer_bin 
                if (Test-Path -Path "$($packer_bin.FullName)") {
                    Remove-Item -Path "$($packer_bin.FullName)"
                    Remove-Item -Path $zip_file
                }           
            }
        }
        else {
            Remove-Item -Path $zip_file
        }
    }   
}

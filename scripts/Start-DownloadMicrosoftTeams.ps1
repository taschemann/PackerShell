#!/usr/bin/env pwsh
# INSTALL PSMSI

#$InstallerSharePath = "\\itsys-sccm.ad.siu.edu\Software$\Microsoft\Teams"
#$temp = "$InstallerSharePath\temp"

$InstallerSharePath = "$env:USERPROFILE\Downloads"
$temp = "$InstallerSharePath\temp"

if (!(Test-Path -Path "$temp")) {
    New-Item -Path "$temp" -ItemType Directory -Force
    Invoke-WebRequest -Uri "https://aka.ms/teams64bitmsi" -OutFile "$temp\teams_x64.msi"
    Invoke-WebRequest -Uri "https://aka.ms/teams32bitmsi" -OutFile "$temp\teams_x86.msi"
}

$msiversion = Get-MSIProperty -Property ProductVersion -Path $temp\teams_x64.msi | Select-Object -ExpandProperty Value

if (!(Test-Path -Path $InstallerSharePath\$msiversion)) {
    @("x86","x64") | ForEach-Object { New-Item -Path "$InstallerSharePath\$msiversion\$_" -ItemType Directory -Force }
    Copy-Item -Path "$temp\teams_x64.msi" -Destination "$InstallerSharePath\$msiversion\x64\teams_x64.msi"
    Copy-Item -Path "$temp\teams_x86.msi" -Destination "$InstallerSharePath\$msiversion\x86\teams_x86.msi"
}

Remove-Item -Path "$temp" -Force -Recurse
#!/usr/bin/env pwsh
# Author: Thomas Aschemann
# INSTALL PSMSI

$InstallerSharePath = "\\itsys-sccm.ad.siu.edu\Software$\Microsoft\Teams"
$temp = "$InstallerSharePath\temp"
$arch = @{"32" = "x86"; "64" = "x64"}

if (!(Test-Path -Path "$temp")) {
    New-Item -Path "$temp" -ItemType Directory -Force
    $arch.keys | ForEach-Object { Invoke-WebRequest -Uri $("https://aka.ms/teams{0}bitmsi" -f $_) -OutFile $("$temp\teams_{0}.msi" -f $arch[$_]) }
}

$msiversion = Get-MSIProperty -Property ProductVersion -Path $temp\teams_x64.msi | Select-Object -ExpandProperty Value

if (!(Test-Path -Path $InstallerSharePath\$msiversion)) {
    $arch.Values | ForEach-Object { New-Item -Path "$InstallerSharePath\$msiversion\$_" -ItemType Directory -Force }
    $arch.Values | ForEach-Object { Copy-Item -Path "$temp\teams_$_.msi" -Destination "$InstallerSharePath\$msiversion\$_\teams_$_.msi" }
}

Start-Sleep -Seconds 10
Remove-Item -Path "$temp" -Force -Recurse
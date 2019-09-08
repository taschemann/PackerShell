#!/usr/bin/env pwsh
# Author: Thomas Aschemann
# INSTALL PSMSI

#$InstallerSharePath = "\\itsys-sccm.ad.siu.edu\Software$\Microsoft\Teams"
#$temp = "$env:TEMP\teams"
$InstallerSharePath = "$env:USERPROFILE\Desktop"
$temp = "$env:TEMP\teams"
$arch = @{"32" = "x86"; "64" = "x64"}

if (!(Test-Path -Path "$temp")) {
    New-Item -Path "$temp" -ItemType Directory -Force
}
elseif ((Test-Path -Path "$temp") -and ((Get-ChildItem -Path $temp | Measure-Object).Count -ne 0)) {
    Write-Warning -Message "$temp must be empty. Attempting to clean..."
    try { Get-Childitem $temp | ForEach-Object { Remove-Item -Confirm:$false -ErrorAction Stop -Force -Recurse -Path "$temp\$_" } }
    catch { Write-Warning $_ }
}

$arch.keys | ForEach-Object { Invoke-WebRequest -Uri $("https://aka.ms/teams{0}bitmsi" -f $_) -OutFile $("$temp\teams_{0}.msi" -f $arch[$_]) }
$msiversion = Get-MSIProperty -Property ProductVersion -Path $temp\teams_x64.msi | Select-Object -ExpandProperty Value

if (!(Test-Path -Path $InstallerSharePath\$msiversion)) {
    foreach ($value in $arch.Values) {
        New-Item -Path "$InstallerSharePath\$msiversion\$value" -ItemType Directory -Force
        Copy-Item -Path "$temp\teams_$value.msi" -Destination "$InstallerSharePath\$msiversion\$value\teams_$value.msi"
    }
}

while ((Get-ChildItem -Path "$temp" | Measure-Object).Count -ne 0) {
    Start-Sleep -Seconds 5
    try { Get-Childitem $temp | ForEach-Object { Remove-Item -Confirm:$false -ErrorAction Stop -Force -Recurse -Path "$temp\$_" } }
    catch { Write-Warning $_ }
}
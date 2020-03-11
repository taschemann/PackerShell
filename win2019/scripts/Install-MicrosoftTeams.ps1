#!/usr/bin/env pwsh
# Author: Thomas Aschemann

#$InstallerSharePath = "\\itsys-sccm.ad.siu.edu\Software$\Microsoft\Teams"
#$temp = "$env:TEMP\teams"
$InstallerSharePath = "$env:USERPROFILE\Desktop"
$temp = "$env:TEMP\teams"
$msiversion = Get-MSIProperty -Property ProductVersion -Path $temp\teams_x64.msi | Select-Object -ExpandProperty Value

if (!(Test-Path -Path "$temp")) {
    
}
elseif ((Test-Path -Path "$temp") -and ((Get-ChildItem -Path $temp | Measure-Object).Count -ne 0)) {
    Write-Warning -Message "$temp must be empty. Attempting to clean..."
    try { Get-Childitem $temp | ForEach-Object { Remove-Item -Confirm:$false -ErrorAction Stop -Force -Recurse -Path "$temp\$_" } }
    catch { Write-Warning $_ }
}

$arch.keys | ForEach-Object { Invoke-WebRequest -Uri $("https://aka.ms/teams{0}bitmsi" -f $_) -OutFile $("$temp\teams_{0}.msi" -f $arch[$_]) }
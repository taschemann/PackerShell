#!/usr/bin/env pwsh

$InstallerSharePath = "\\itsys-sccm.ad.siu.edu\Software$\Microsoft\Teams"
$tmp = "$InstallerSharePath\tmp"

if (!(Test-Path -Path "$tmp")) {
    New-Item -Path "$tmp" -ItemType Directory 
}

$CurrentVersion = Invoke-WebRequest -Uri "https://aka.ms/teams64bitmsi" -OutFile "$tmp\teams_x64.msi"

Invoke-WebRequest -Uri "$CurrentVersion"

Remove-Item -Path "$tmp" -Force
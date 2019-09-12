#!/usr/bin/env pwsh
# Author: Thomas Aschemann
# INSTALL PSMSI

$InstallerSharePath = "\\itsys-sccm.ad.siu.edu\Software$\Microsoft\Teams"
$temp = "$env:SystemDrive\Temp"
$arch = @{"32" = "x86"; "64" = "x64"}

if (!(Test-Path -Path "$temp")) {
    New-Item -Path "$temp" -ItemType Directory -Force
}

$arch.keys | ForEach-Object { Invoke-WebRequest -Uri $("https://aka.ms/teams{0}bitmsi" -f $_) -OutFile $("$temp\teams_{0}.msi" -f $arch[$_]) }
$msiversion = Get-MSIProperty -Property ProductVersion -Path $temp\teams_x64.msi | Select-Object -ExpandProperty Value
$body = @"
    {"text":"Adjutant Online. Microsoft Teams version $msiversion is available."}
"@
$splat = @{
    "Method" = "Post"
    "ContentType" = "Application/Json"
    "Body" = $body
    "Uri" = "https://outlook.office.com/webhook/a34d3ac2-ae62-4792-8c94-e453dd5646ce@d57a98e7-744d-43f9-bc91-08de1ff3710d/IncomingWebhook/cb5def3f8d3c43deb6429bf31e6eb41d/0346bb91-bfa3-462c-ae57-205a05da36eb"
}

if (!(Test-Path -Path "$InstallerSharePath\$msiversion")) {
    Invoke-RestMethod @splat
    foreach ($value in $arch.Values) {
        New-Item -Path "$InstallerSharePath\$msiversion\$value" -ItemType Directory -Force
        do {
            Start-Sleep -Seconds 3
            Move-Item -Path "$temp\teams_$value.msi" -Destination "$InstallerSharePath\$msiversion\$value\teams_$value.msi" -Force -Confirm:$false
        } while (-not $?)
    }
}
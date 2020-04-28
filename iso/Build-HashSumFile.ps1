
[CmdletBinding()]
param (
    [Parameter()]
    [string]$Path = "$PSScriptRoot"
)

$PSScriptRoot
$images = Get-ChildItem -Path "$Path" | Where-Object { $_.Extension -eq ".ISO" } | Select-Object -Property Name,BaseName,FullName,Directory

foreach ($iso in $images) {
    if (-not(Test-Path -Path "$($iso.Directory)\$($iso.BaseName)_checksum.txt")) {
        New-Item -Path "$($iso.Directory)" -Name "$($iso.BaseName)_checksum.txt"
        $hash = Get-FileHash -Path "$($iso.FullName)" -Algorithm SHA256
        "$($hash.Hash)  $($iso.Name)" > "$($iso.Directory)\$($iso.BaseName)_checksum.txt"
    }
}


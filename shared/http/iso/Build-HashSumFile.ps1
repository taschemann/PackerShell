
[CmdletBinding()]
param (
    [Parameter()]
    [string]$Path = "$PSScriptRoot"
)

$images = Get-ChildItem -Path "$Path" | Where-Object { $_.Extension -eq ".ISO" } | Select-Object -Property Name,BaseName,FullName,Directory
$checksum_path = "$Path\checksums"

foreach ($iso in $images) {
    if (-not(Test-Path -Path "$checksum_path\$($iso.BaseName)_checksum.txt")) {
        New-Item -Path "$checksum_path" -Name "$($iso.BaseName)_checksum.txt"
        $hash = Get-FileHash -Path "$($iso.FullName)" -Algorithm SHA256
        "$($hash.Hash.ToLower())  $($iso.Name)" > "$checksum_path\$($iso.BaseName)_checksum.txt"
    }
}
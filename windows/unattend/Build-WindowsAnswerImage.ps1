#Script used to create answer.iso files for secondary_iso_images
#Author: Thomas Aschemann

$unattend_root = "$PSScriptRoot"
$unattend_files = Get-ChildItem -Recurse $unattend_root -File | Where-Object {$_.Directoryname -ne "$unattend_root"}

if (($IsWindows) -and ($env:PROCESSOR_ARCHITECTURE -eq "amd64")) {
    $build_utils = "..\Deployment Tools\amd64"

    foreach ($file in $unattend_files) {
        if (Test-Path -Path "$($file.DirectoryName)\answer.iso") {
            Remove-Item -Path "$($file.DirectoryName)\answer.iso"
        }
        Start-Process -FilePath "$build_utils\Oscdimg\oscdimg.exe" -ArgumentList "-lWIN_ANSWER_ISO -m -u2 $($file.DirectoryName) $($file.DirectoryName)\answer.iso"
    }
}
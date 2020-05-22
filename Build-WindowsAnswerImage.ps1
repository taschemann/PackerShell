#Script used to create answer.iso files for secondary_iso_images
#Author: Thomas Aschemann

$packer_root = "$PSScriptRoot"
$unattend_root = "$packer_root\unattend"
$unattend_files = Get-ChildItem -Recurse $unattend_root -File | Where-Object {($_.Directoryname -ne "$unattend_root") -and ($_.Extension -ne ".iso")}

if (($IsWindows) -and ($env:PROCESSOR_ARCHITECTURE -eq "amd64")) {
    $build_utils = "$packer_root\bin\Deployment Tools\amd64"

    if (-not (Test-Path "$build_utils\Oscdimg\oscdimg.exe")) {
        throw "oscdimg.exe not found. Please install the Windows Deployment Tools from the Windows Assessment and Deployment Toolkit."
    }

    foreach ($file in $unattend_files) {
        if (Test-Path -Path "$($file.DirectoryName)\answer.iso") {
            Remove-Item -Path "$($file.DirectoryName)\answer.iso"
        }
        Start-Process -FilePath "$build_utils\Oscdimg\oscdimg.exe" -ArgumentList "-lWIN_ANSWER_ISO -m -u2 $($file.DirectoryName) $($file.DirectoryName)\answer.iso" -Wait -NoNewWindow
    }
}
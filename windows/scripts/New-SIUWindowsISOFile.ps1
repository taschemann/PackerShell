# Note, only tested on Windows 10 build 9860, x64 Enterprise edition.
# The native DISM cmdlets didn't like the ESD files very much, so using dism.exe instead.
#https://deploymentresearch.com/how-to-really-create-a-windows-10-build-10041-iso-no-3rd-party-tools-needed/

#$ESDFile = 'C:RecoveryImageInstall.esd'
#$ISOMediaFolder = 'C:ISOMedia'
#$ISOFile = 'C:ISOWindows10_build9860.iso'
#$PathToOscdimg = 'C:oscdimg'

Write-Output "Checking for oscdimg.exe"
If (Test-Path $PathToOscdimgoscdimg.exe){
    Write-Output "Oscdimg.exe found, OK, continuing..."
    Write-Output ""
    }
Else {
    Write-Output "Cannot find oscdimg.exe. Aborting"
    Break
}

# Create ISO folder structure
New-Item -ItemType Directory $ISOMediaFolder
dism.exe /Apply-Image /ImageFile:$ESDFile /Index:1 /ApplyDir:$ISOMediaFolder

# Create empty boot.wim file with compression type set to maximum
New-Item -ItemType Directory 'C:EmptyFolder'
dism.exe /Capture-Image /ImageFile:$ISOMediaFoldersourcesboot.wim /CaptureDir:C:EmptyFolder /Name:EmptyIndex /Compress:max

# Export base Windows PE to empty boot.wim file (creating a second index)
dism.exe /Export-image /SourceImageFile:$ESDFile /SourceIndex:2 /DestinationImageFile:$ISOMediaFoldersourcesboot.wim /Compress:Recovery /Bootable

# Delete the first empty index in boot.wim
dism.exe /Delete-Image /ImageFile:$ISOMediaFoldersourcesboot.wim /Index:1

# Export Windows PE with Setup to boot.wim file
dism.exe /Export-image /SourceImageFile:$ESDFile /SourceIndex:3 /DestinationImageFile:$ISOMediaFoldersourcesboot.wim /Compress:Recovery /Bootable

# Display info from the created boot.wim
dism.exe /Get-WimInfo /WimFile:$ISOMediaFoldersourcesboot.wim

# Create empty install.wim file with MDT/ConfigMgr friendly compression type (maximum)
dism.exe /Capture-Image /ImageFile:$ISOMediaFoldersourcesinstall.wim /CaptureDir:C:EmptyFolder /Name:EmptyIndex /Compress:max

# Export Windows Technical Preview to empty install.wim file
dism.exe /Export-image /SourceImageFile:$ESDFile /SourceIndex:4 /DestinationImageFile:$ISOMediaFoldersourcesinstall.wim /Compress:Recovery

# Delete the first empty index in install.wim
dism.exe /Delete-Image /ImageFile:$ISOMediaFoldersourcesinstall.wim /Index:1

# Display info from the created install.wim
dism.exe /Get-WimInfo /WimFile:$ISOMediaFoldersourcesinstall.wim

# Create the Windows Technical Preview ISO
# For more info on the Oscdimg.exe commands, check this post: http://support2.microsoft.com/kb/947024

$BootData='2#p0,e,b"{0}"#pEF,e,b"{1}"' -f "$ISOMediaFolderbootetfsboot.com","$ISOMediaFolderefiMicrosoftbootefisys.bin"

$Proc = Start-Process -FilePath "$PathToOscdimgoscdimg.exe" -ArgumentList @("-bootdata:$BootData",'-u2','-udfver102',"$ISOMediaFolder","$ISOFile") -PassThru -Wait -NoNewWindow
if($Proc.ExitCode -ne 0)
{
    Throw "Failed to generate ISO with exitcode: $($Proc.ExitCode)"
}
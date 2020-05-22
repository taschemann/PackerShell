# Intro to PackerShell

PackerShell is a build lab used for easily constructing Windows images with Packer. It is designed to read the names of your ISO files to determine which versions of Windows you have available to build.

PackerShell will support building images for both UEFI and BIOS VMs of Windows desktop and server. Currently the packer templates and variable files only support the hyperv-iso builder but this project is intended to run on any platform that supports both Packer and PowerShell 7. Since it's still very early days, testing is only done on Windows and I use hyper-v professionally, so it is a higher priority to get it working.

PackerShell also makes it easy to build and rebuild answer.iso files to give to Packer as a secondary ISO image. You will need to install the Windows Deployment Tools from the Windows Assessment and Deployment Toolkit. As of this writing, the build tools are on version 1903 and are likely to stay at that version. Once the deployment tools are installed, you'll need to copy/cut and paste the Deployment Tools folder to the bin folder of this project. Once that's done, simply run the Build-WindowsAnswerImage.ps1 script. I realize this is a Windows-only solution. If anybody has recommendations for a cross-platform ISO builder, I'm open to suggestions.

Windows ADK: https://docs.microsoft.com/en-us/windows-hardware/get-started/adk-install

ISOs must be named a certain way for the script to detect them properly. The format of each ISO name should be:
> [osname]-[version]-[(server or desktop)]-[arch].iso

> windows-1909-desktop-x64.iso

> windows-1909-desktop-x86.iso

> windows-ltsc2019-desktop-x64.iso

> windows-2019-server-x64.iso

``` powershell
Import-Module -Name ".\Build-PackerWindowsImage.ps1" -Force
Build-PackerImage [-Parameters]
```
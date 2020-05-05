# Intro to PackerShell

PackerShell is a Packer build lab implemented in PowerShell 7. It is designed to easily build Packer images from a base ISO. PackerShell can detect which ISOs are available and will offer different parameters and parameter values based on which operating system you want to build.

When it is complete, PackerShell will support building Windows 10, Windows Server 2016 and 2019, Ubuntu Server and Desktop versions 18.04 and 20.04, and CentOS 7 and 8 from a base ISO. Currently it only works for Windows and variables are only set for the hyperv-iso builder.

The primary script Build-PackerImage can detect which ISOs are available and will dynamically offer parameters based on which operating system you choose. As an example, if you're wanting to build a Windows image, you would set the -OSName parameter of the Build-PackerImage function to 'windows'. Build-PackerImage will now offer you Windows-specific parameters, such as -WindowsSKU and -WindowsVersion.

ISOs must be named a certain way for the script to detect them properly. The format of each ISO name should be:
> [osname]-[version]-[(server or desktop)]-[arch].iso


> windows-1909-desktop-x64.iso

> windows-ltsc2019-desktop-x64.iso

> windows-2019-server-x64.iso

> ubuntu-20.04-desktop-x64.iso

> ubuntu-20.04-server-x64.iso

``` powershell
Import-Module -Name ".\Build-PackerImage.ps1" -Force
Build-PackerImage [-Parameters]
```
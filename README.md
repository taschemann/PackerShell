# Intro to PackerShell

PackerShell is a Packer build lab implemented in PowerShell 7. It is designed to easily build Packer images from a base ISO. PackerShell can detect which ISOs are available and will offer different parameters and parameter values based on which operating system you want to build.

When it is complete, PackerShell will support building images for both UEFI and BIOS VMs of Windows 10, Windows Server 2016 and 2019, Ubuntu Server and Desktop versions 18.04 and 20.04, and CentOS 7 and 8 from a base ISO. Currently it only builds Windows and variables are only set for the hyperv-iso builder. This project is intended to run on any platform that supports both Packer and PowerShell 7. Since it's still very early days, testing is only done on Windows currently.

The basic gist of this project is it takes user input through PowerShell parameters, dumps those values into a Packer variable file, and then feeds the variable file to a Packer build template. The hypervisor that Packer uses depends on the build template the user selects with the -PackerTemplateFile parameter. The name of the template file should indicate this. A user can only select one build template at a time but can have multiple variable files in a comma-separated list, which can be defined with the -PackerVariableFile parameter. Any conflicts between variable files are sorted by the order in which the files are listed; the last file wins the conflict. So if two or more variable files define a variable, say vm_name, the last file that sets a value for vm_name will be the value that Packer uses.

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

## Project Structure
/builds - Output directory for packer artifacts

/centos - CentOS packer template files and centos-specific resources

/logs - Build-PackerImage transcripts and packer.exe logs

/shared - shared resources such as scripts, templates, var files, local playbooks, and the http root

/shared/http - HTTP root folder. Files in here will be available in a Packer deployment via http://{{ .HTTPIP }}:{{ .HTTPPort }}

/shared/http/iso - ISO files go here

/ubuntu - Ubuntu packer template files and ubuntu-specific resources

/windows - Windows packer template files, unattend files, and Windows build tools

/Build-PackerImage.ps1 - primary script file

/Start-DownloadPacker.ps1 - Download script for latest packer.exe. Downloads to local directory.
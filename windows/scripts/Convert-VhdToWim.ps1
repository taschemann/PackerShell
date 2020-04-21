[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string] $OutputPath = "$env:USERPROFILE\wim_files",
    [Parameter(Mandatory)]
    [string] $VhdPath,
    [Parameter(Mandatory)]
    [string] $ImageName = "captured_vhd.wim",
    [Parameter(Mandatory)]
    [string] $MountPath = "C:\Mount"
)

if (-not ( Test-Path -Path $MountPath )) {
    New-Item -ItemType Directory -Path $MountPath -Force
}

if (-not ( Test-Path -Path $OutputPath )) {
    New-Item -ItemType Directory -Path $OutputPath -Force
}

Mount-WindowsImage -ImagePath $VhdPath -Path $MountPath -Index 1
New-WindowsImage -CapturePath $MountPath -Name $ImageName -ImagePath $OutputPath -Description $ImageName -Verify
Dismount-WindowsImage -Path $MountPath -Discard
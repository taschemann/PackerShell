[CmdletBinding()]
param (
    [Parameter()]
    [string] $VMName = "packer-winserver_$(Get-Date -UFormat "%d%b%Y_%H%M")",
    [Parameter(Mandatory)]
    [ValidateSet("hyperv-iso","vSphere-iso","all")]
    [string] $BuildType = "hyperv-iso",
    [Parameter(Mandatory)]
    [ValidateSet("win2016","win2019")]
    [string] $OSName,
    [Parameter()]
    [string[]] $IsoUrl,
    [Parameter(Mandatory)]
    [ValidateSet("bios","uefi")]
    [string] $Firmware,
    [Parameter(Mandatory)]
    [ValidateSet("standard","datacenter","standardcore","datacentercore")]
    [string] $OSSKU,
    [Parameter()]
    [string] $OutputPath = ".\output"
)

if (Test-Path -Path $OutputPath) {
    Remove-Item -Path $OutputPath -Force -Recurse
}

switch ($OSName) {
    'win2016' { 
        $packer_data = @{
            os_name = "$_"
            vm_name = "packer-$($_)_$(Get-Date -UFormat "%d%b%Y_%H%M")"
            build_type = "$BuildType"
        }
    }

    'win2019' {
        switch ($OSSKU) {
            'standard' { $unattend_path = ".\unattend\$Firmware\serverstandard\autounattend.xml" }
            'datacenter' { $unattend_path = ".\unattend\$Firmware\serverdatacenter\autounattend.xml" }
            'standardcore' { $unattend_path = ".\unattend\$Firmware\serverstandardcore\autounattend.xml" }
            'datacentercore' { $unattend_path = ".\unattend\$Firmware\serverdatacentercore\autounattend.xml" }
        }

        if ($BuildType -eq "all") {
            $BuildType = @("hyperv-iso","vSphere-iso")
        }

        $packer_data = @{
            os_name = "$($_)"
            vm_name = "packer-$($_)_$(Get-Date -UFormat "%d%b%Y_%H%M")"
            build_type = "$BuildType"
            iso_url = "$IsoUrl"
            unattend_file = "$unattend_path"
            cpu = 4
            ram_size = 8192
            disk_size = 40000
            output_directory = "$OutputPath"
        }

        $packer_data
    }
}

# Run the build in multiple steps to prevent loss of time in case a build fails somewhere in the middle.

# Build Base Image
#Write-Host "build -var os_name=$($packer_data.os_name) -var vm_name=$($packer_data.vm_name) `
#    -var iso_url=$($packer_data.iso_url) -var `"unattend_file=$($packer_data.unattend_file)`" -var cpu=$($packer_data.cpu) `
#    -var ram_size=$($packer_data.ram_size) -var disk_size=$($packer_data.disk_size) -var `"output_directory=$($packer_data.output_directory)`" `
#    .\01_winserver_base.json -only=$BuildType" 

Start-Process -FilePath 'packer.exe' -ArgumentList "build -var `"os_name=$($packer_data.os_name)`" -var `"vm_name=$($packer_data.vm_name)`" -var `"iso_url=$($packer_data.iso_url)`" -var `"unattend_file=$($packer_data.unattend_file)`" -var `"cpu=$($packer_data.cpu)`" -var `"ram_size=$($packer_data.ram_size)`" -var `"disk_size=$($packer_data.disk_size)`" -var `"output_directory=$($packer_data.output_directory)`" .\01_winserver_base.json" -Wait -NoNewWindow

# Build Image with Updates
#Start-Process -FilePath 'packer.exe' -ArgumentList "build -var `"os_name=$($packer_data.os_name)`" .\02_winserver_updates.json" -Wait -NoNewWindow

# CLeanup Updated Image
#Start-Process -FilePath 'packer.exe' -ArgumentList "build -var `"os_name=$($packer_data.os_name)`" .\03_winserver_cleanup.json" -Wait -NoNewWindow
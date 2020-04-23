[CmdletBinding()]
param (
    ##
    [Parameter(ParameterSetName="HyperV", Position=0)]
    [switch] $BuildHyperV,
    ##
    [Parameter(ParameterSetName="vSphere", Position=0)]
    [switch] $BuildvSphere,
    ##
    [Parameter(Position=0)]
    [switch] $BuildAll,
    ##
    [Parameter(Mandatory, Position=1)]
    [ValidateSet("windows","centos","ubuntu")]
    [string[]] $OSName,
    ##
    [Parameter(Mandatory, ParameterSetName="CentOS", Position=2)]
    [ValidateSet("7","8")]
    [string[]] $CentOSVersion,
    ##
    [Parameter(Mandatory, ParameterSetName="Ubuntu", Position=2)]
    [ValidateSet("18.04","20.04")]
    [string[]] $UbuntuVersion,
    ##
    [ValidateSet("desktop","server")]
    [string[]] $BuildType,
    ##
    [Parameter(Mandatory, ParameterSetName="HyperV")]
    [Parameter(Mandatory, ParameterSetName="vSphere")]
    [string[]] $IsoUrl,
    ##
    [Parameter(Mandatory, ParameterSetName="HyperV")]
    [Parameter(Mandatory, ParameterSetName="vSphere")]
    [ValidateSet("bios","uefi")]
    [string] $Firmware = "bios",
    ##
    [Parameter(ParameterSetName="HyperV")]
    [Parameter(ParameterSetName="vSphere")]
    [Parameter(ParameterSetName="Windows")]
    [ValidateSet("SERVERSTANDARD","SERVERSTANDARDCORE","SERVERDATACENTER","SERVERDATACENTERCORE","ENTERPRISE","PROFESSIONAL")]
    [string] $WindowsSKU = "SERVERSTANDARD",
    ##
    [Parameter(ParameterSetName="HyperV")]
    [Parameter(ParameterSetName="vSphere")]
    [string] $OutputPath = ".\output",
    ##
    [Parameter()]
    [ValidateSet("BuildBaseImage","BuildUpdatedBaseImage","CleanupBaseImage")]
    [string] $BuildStep,
    ##
    [Parameter(ParameterSetName="HyperV")]
    [switch] $EnableSecureBoot,
    ##
    [Parameter(ParameterSetName="HyperV")]
    [Parameter(ParameterSetName="vSphere")]
    [string] $VMName = "packer_$OSName_$(Get-Date -UFormat "%d%b%Y_%H%M")",
    ##
    [Parameter()]
    [int] $ProcessorCount = 2,
    ##
    [Parameter()]
    [int] $MemoryInMegabytes = 2048,
    ##
    [Parameter()]
    [int] $DiskSizeInMegabytes = 25000
)

BEGIN {
    if (Test-Path -Path $OutputPath) {
        Remove-Item -Path $OutputPath -Force -Recurse
    }

    if (($BuildType -eq "desktop") -and ($WindowsSKU -ne ("ENTERPRISE" -or "PROFESSIONAL"))) {
        throw "Desktop builds must use the ENTERPRISE or PROFESSIONAL SKU."
    }
}

PROCESS {
    foreach ($os in $OSName) {
        switch ($os) {
    
            'windows' {
                switch ($WindowsSKU) {
                    'standard' { $unattend_path = ".\windows\unattend\$Firmware\serverstandard\autounattend.xml" }
                    'datacenter' { $unattend_path = ".\windows\unattend\$Firmware\serverdatacenter\autounattend.xml" }
                    'standardcore' { $unattend_path = ".\windows\unattend\$Firmware\serverstandardcore\autounattend.xml" }
                    'datacentercore' { $unattend_path = ".\windows\unattend\$Firmware\serverdatacentercore\autounattend.xml" }
                    'enterprise' { $unattend_path = ".\windows\unattend\$Firmware\enterprise\autounattend.xml" }
                    'professional' { $unattend_path = ".\windows\unattend\$Firmware\professional\autounattend.xml" }
                }
        
                $packer_data = @{
                    os_name = "$($_)"
                    vm_name = "$VMName"
                    build_type = "$BuildType"
                    iso_url = "$IsoUrl"
                    unattend_file = "$unattend_path"
                    cpu = $ProcessorCount
                    ram_size = $MemoryInMegabytes
                    disk_size = $DiskSizeInMegabytes
                    output_directory = "$OutputPath"
                }
            }
        
            'centos' {
        
                $packer_data = @{
                    os_name = "$($_)"
                    vm_name = "$VMName"
                    build_type = "$BuildType"
                    iso_url = "$IsoUrl"
                    unattend_file = "$unattend_path"
                    cpu = $ProcessorCount
                    ram_size = $MemoryInMegabytes
                    disk_size = $DiskSizeInMegabytes
                    output_directory = "$OutputPath"
                }
            }
        
            'ubuntu' {
        
                $packer_data = @{
                    os_name = "$($_)"
                    vm_name = "$VMName"
                    build_type = "$BuildType"
                    iso_url = "$IsoUrl"
                    unattend_file = "$unattend_path"
                    cpu = $ProcessorCount
                    ram_size = $MemoryInMegabytes
                    disk_size = $DiskSizeInMegabytes
                    output_directory = "$OutputPath"
                }
            }
        }
        
        # Run the build in multiple steps to prevent loss of time in case a build fails somewhere in the middle.
        
        # Build Base Image
        if (((-not $BuildStep) -or ($BuildStep -eq "BuildBaseImage")) -and ($BuildHyperV) ) {
            if ($Firmware -eq "bios") {
                Start-Process -FilePath 'packer.exe' -ArgumentList "build -only=hyperv-bios -var `"os_name=$($packer_data.os_name)`" -var `"vm_name=$($packer_data.vm_name)`" -var `"iso_url=$($packer_data.iso_url)`" -var `"unattend_file=$($packer_data.unattend_file)`" -var `"cpu=$($packer_data.cpu)`" -var `"ram_size=$($packer_data.ram_size)`" -var `"disk_size=$($packer_data.disk_size)`" -var `"output_directory=$($packer_data.output_directory)`" .\windows\server_01_base.json" -Wait -NoNewWindow   
            } elseif ($Firmware -eq "uefi") {
                Start-Process -FilePath 'packer.exe' -ArgumentList "build -only=hyperv-uefi -var `"os_name=$($packer_data.os_name)`" -var `"vm_name=$($packer_data.vm_name)`" -var `"iso_url=$($packer_data.iso_url)`" -var `"unattend_file=$($packer_data.unattend_file)`" -var `"cpu=$($packer_data.cpu)`" -var `"ram_size=$($packer_data.ram_size)`" -var `"disk_size=$($packer_data.disk_size)`" -var `"output_directory=$($packer_data.output_directory)`" .\windows\server_01_base.json" -Wait -NoNewWindow
            }
        }
        # Build Image with Updates
        #if (($null -eq $BuildStep) -or ($BuildStep -eq "BuildUpdatedBaseImage")) {
        #    Start-Process -FilePath 'packer.exe' -ArgumentList "build -var `"os_name=$($packer_data.os_name)`" .\02_winserver_updates.json" -Wait -NoNewWindow
        #}
        # Cleanup Updated Image
        #if (($null -eq $BuildStep) -or ($BuildStep -eq "CleanupBaseImage")) {
        #    Start-Process -FilePath 'packer.exe' -ArgumentList "build -var `"os_name=$($packer_data.os_name)`" .\03_winserver_cleanup.json" -Wait -NoNewWindow
        #}
    }
}

END {}
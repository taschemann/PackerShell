
function New-SIUPackerHypervisorInstance {
    [CmdletBinding()]
    param (
        ##
        [Parameter(Mandatory, Position = 0)]
        [ValidateSet("HyperV","Vsphere","Virtualbox")]
        [string] $HypervisorPlatform,
        ##
        [Parameter(Position = 1)]
        [string] $VMName = "packer_$(Get-Date -UFormat "%d%b%Y_%H%M")",
        ##
        [Parameter(Position = 2)]
        [int] $CPU = 1,
        ##
        [Parameter()]
        [int] $DiskSizeInMegabytes = 25000,
        ##
        [Parameter()]
        [int] $MemorySizeInMegabytes = 2048
    )

    DynamicParam {
        if ($HypervisorPlatform -eq 'Vsphere') {

            $param_cpucores = "CPUCores"
            #WindowsVersion parameter
            $CPUCores = New-Object -TypeName System.Management.Automation.ParameterAttribute
            $CPUCores.Position = 3
            $CPUCores.Mandatory = $true

            $attribute_collection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
            $attribute_collection.Add($CPUCores)
    
            $dynamic_parameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter($param_cpucores, [int32], $attribute_collection)
            $parameter_dictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
            $parameter_dictionary.Add($param_cpucores, $dynamic_parameter)
            return $parameter_dictionary
        }
        elseif ($HypervisorPlatform -eq 'HyperV') {
            $param_generation = "Generation"

            #HyperV VM Generation parameter
            $Generation = New-Object -TypeName System.Management.Automation.ParameterAttribute
            $Generation.Mandatory = $true

            $validate_set_attribute = New-Object -TypeName System.Management.Automation.ValidateSetAttribute -ArgumentList '1','2'
            $attribute_collection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
            $attribute_collection.Add($Generation)
            $attribute_collection.Add($validate_set_attribute)
    
            $dynamic_parameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter($param_generation, [string], $attribute_collection)
            $parameter_dictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
            $parameter_dictionary.Add($param_generation, $dynamic_parameter)
            return $parameter_dictionary
        }
    }
    
    BEGIN {
        if ($HypervisorPlatform -eq 'Vsphere') {
            # This is essential for the dynamic parameters to be recognized.
            $CPUCoresObj = $PSBoundParameters[$param_cpucores]
        }
        elseif ($HypervisorPlatform -eq 'HyperV') {
            # This is essential for the dynamic parameters to be recognized.
            $GenerationObj = $PSBoundParameters[$param_generation]
        }
    }

    PROCESS {
        switch ($HypervisorPlatform) {
            "HyperV" {
                return $hypervisor_instance = @{
                    hypervisor = $($_)
                    cpu = $CPU
                    ram_size = $MemorySizeInMegabytes
                    disk_size = $DiskSizeInMegabytes
                    vm_name = $VMName
                    generation = $GenerationObj       
                }
            }
        
            "Vsphere" { 
                return $hypervisor_instance = @{
                    hypervisor = $($_)
                    cpu = $CPU
                    cpu_core = $CPUCoresObj
                    ram_size = $MemorySizeInMegabytes
                    disk_size = $DiskSizeInMegabytes
                    vm_name = $VMName
                }
            }
        
            "Virtualbox" { 
                return $hypervisor_instance = @{
                    hypervisor = $($_)
                    cpu = $CPU
                    ram_size = $MemorySizeInMegabytes
                    disk_size = $DiskSizeInMegabytes
                    vm_name = $VMName
                }
            }
        }
    }
    END {}
}
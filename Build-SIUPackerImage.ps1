#Requires -Version 7

class OperatingSystemValidValues : System.Management.Automation.IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $isos = Get-ChildItem -Path ".\iso\" | Where-Object { $_.Extension -eq ".iso" } | ForEach-Object { $_.BaseName -split '-' }
        $valid_values = @()
        for ($i = 0; $i -lt $isos.Length; $i+=4) {
            $valid_values += $isos[$i]
        }
        return $($valid_values | Sort-Object | Get-Unique)
    }
}

class OperatingSystemVersionValidValues : System.Management.Automation.IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $isos = Get-ChildItem -Path ".\iso\" | Where-Object { $_.Extension -eq ".iso" } | ForEach-Object { $_.BaseName -split '-' }
        $valid_values = @()
        for ($i = 1; $i -lt $isos.Length; $i+=4) {
            $valid_values += $isos[$i]
        }
        return $($valid_values | Sort-Object | Get-Unique)
    }
}

class OperatingSystemBuildTypeValidValues : System.Management.Automation.IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $isos = Get-ChildItem -Path ".\iso\" | Where-Object { $_.Extension -eq ".iso" } | ForEach-Object { $_.BaseName -split '-' }
        $valid_values = @()
        for ($i = 2; $i -lt $isos.Length; $i+=4) {
            $valid_values += $isos[$i]
        }
        return $($valid_values | Sort-Object | Get-Unique)
    }
}

class OperatingSystemArchitectureValidValues : System.Management.Automation.IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $isos = Get-ChildItem -Path ".\iso\" | Where-Object { $_.Extension -eq ".iso" } | ForEach-Object { $_.BaseName -split '-' }
        $valid_values = @()
        for ($i = 3; $i -lt $isos.Length; $i+=4) {
            $valid_values += $isos[$i]
        }
        return $($valid_values | Sort-Object | Get-Unique)
    }
}

function Build-SIUPackerImage {
    [CmdletBinding()]
    param (
        ##
        [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName)]
        [ValidateSet("HyperV","Vsphere","Virtualbox")]
        [string] $HypervisorPlatform,
        ##
        [Parameter(Mandatory, Position=1)]
        [ValidateSet([OperatingSystemValidValues])]
        [string[]] $OSName,
        ##
        [Parameter(Mandatory, Position=2)]
        [ValidateSet([OperatingSystemVersionValidValues])]
        [string[]] $OSVersion,
        ##
        [Parameter(Mandatory, Position=3)]
        [ValidateSet([OperatingSystemBuildTypeValidValues])]
        [string[]] $OSType,
        ##
        [Parameter()]
        [ValidateSet([OperatingSystemArchitectureValidValues])]
        [string[]] $OSArch,
        ##
        [Parameter()]
        [string] $OutputPath = "$pwd\builds",
        ##
        [Parameter()]
        [ValidateSet("BuildBaseImage","BuildUpdatedBaseImage","CleanupBaseImage")]
        [string] $BuildStep,
        ##
        [Parameter()]
        [hashtable[]] $InputObject
    )

    DynamicParam {
        if ($OSName -eq 'windows') {
            if ($BuildType -eq 'server') {

                $param_winversion = "WindowsVersion"
                $param_winsku = "WindowsSKU"
                $param_winuanttend = "WindowsUnattendFile"

                #WindowsVersion parameter
                $WindowsVersion = New-Object -TypeName System.Management.Automation.ParameterAttribute
                $WindowsVersion.Position = 1
                $WindowsVersion.Mandatory = $true
    
                $validate_set_attribute = New-Object -TypeName System.Management.Automation.ValidateSetAttribute -ArgumentList '2016','2019'
                $attribute_collection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
                $attribute_collection.Add($WindowsVersion)
                $attribute_collection.Add($validate_set_attribute)
        
                $dynamic_parameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter($param_winversion, [string], $attribute_collection)
                $parameter_dictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
                $parameter_dictionary.Add($param_winversion, $dynamic_parameter)

                #WindowsSKU parameter
                $WindowsSKU = New-Object -TypeName System.Management.Automation.ParameterAttribute
                $WindowsSKU.Position = 2
                $WindowsSKU.Mandatory = $true
    
                $validate_set_attribute = New-Object -TypeName System.Management.Automation.ValidateSetAttribute -ArgumentList 'SERVERSTANDARD','SERVERSTANDARDCORE','SERVERDATACENTER','SERVERDATACENTERCORE'
                $attribute_collection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
                $attribute_collection.Add($WindowsSKU)
                $attribute_collection.Add($validate_set_attribute)
        
                $dynamic_parameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter($param_winsku, [string], $attribute_collection)
                $parameter_dictionary.Add($param_winsku, $dynamic_parameter)

                #WindowsUnattendFile parameter
                $WindowsUnattend = New-Object -TypeName System.Management.Automation.ParameterAttribute
                $WindowsUnattend.Position = 3
                $WindowsUnattend.Mandatory = $false
    
                $attribute_collection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
                $attribute_collection.Add($WindowsUnattend)
        
                $dynamic_parameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter($param_winuanttend, [string], $attribute_collection)
                $parameter_dictionary.Add($param_winuanttend, $dynamic_parameter)
                return $parameter_dictionary
            }
            
            elseif ($BuildType -eq 'desktop') {
                $param_winversion = "WindowsVersion"
                $param_winsku = "WindowsSKU"
                $param_winuanttend = "WindowsUnattendFile"

                #WindowsVersion parameter
                $WindowsVersion = New-Object -TypeName System.Management.Automation.ParameterAttribute
                $WindowsVersion.Position = 1
                $WindowsVersion.Mandatory = $true
    
                $validate_set_attribute = New-Object -TypeName System.Management.Automation.ValidateSetAttribute -ArgumentList '1909','2004','LTSB2016','LTSB2019'
                $attribute_collection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
                $attribute_collection.Add($WindowsVersion)
                $attribute_collection.Add($validate_set_attribute)
        
                $dynamic_parameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter($param_winversion, [string], $attribute_collection)
                $parameter_dictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
                $parameter_dictionary.Add($param_winversion, $dynamic_parameter)
                
                #WindowsSKU parameter
                $WindowsSKU = New-Object -TypeName System.Management.Automation.ParameterAttribute
                $WindowsSKU.Position = 2
                $WindowsSKU.Mandatory = $true
    
                $validate_set_attribute = New-Object -TypeName System.Management.Automation.ValidateSetAttribute -ArgumentList 'ENTERPRISE','PROFESSIONAL'
                $attribute_collection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
                $attribute_collection.Add($WindowsSKU)
                $attribute_collection.Add($validate_set_attribute)
        
                $dynamic_parameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter($param_winsku, [string], $attribute_collection)
                $parameter_dictionary.Add($param_winsku, $dynamic_parameter)

                #WindowsUnattendFile parameter
                $WindowsUnattend = New-Object -TypeName System.Management.Automation.ParameterAttribute
                $WindowsUnattend.Position = 3
                $WindowsUnattend.Mandatory = $false
    
                $attribute_collection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
                $attribute_collection.Add($WindowsUnattend)
        
                $dynamic_parameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter($param_winuanttend, [string], $attribute_collection)
                $parameter_dictionary.Add($param_winuanttend, $dynamic_parameter)
                return $parameter_dictionary
            }
        }
        elseif ($OSName -eq 'ubuntu') {
            $param_ubuntuversion = "UbuntuVersion"

            #UbuntuVersion parameter
            $UbuntuVersion = New-Object -TypeName System.Management.Automation.ParameterAttribute
            $UbuntuVersion.Position = 1
            $UbuntuVersion.Mandatory = $true

            $validate_set_attribute = New-Object -TypeName System.Management.Automation.ValidateSetAttribute -ArgumentList '18.04','20.04'
            $attribute_collection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
            $attribute_collection.Add($UbuntuVersion)
            $attribute_collection.Add($validate_set_attribute)
    
            $dynamic_parameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter($param_ubuntuversion, [string], $attribute_collection)
            $parameter_dictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
            $parameter_dictionary.Add($param_ubuntuversion, $dynamic_parameter)
            return $parameter_dictionary
        }
        elseif ($OSName -eq "centos") {
            $CentOSVersion = New-Object -TypeName "System.Management.Automation.ParameterAttribute"
            $CentOSVersion.ParameterSetName = "CentOS"
            $CentOSVersion.Mandatory = $true
            $CentOSVersion.ValidateSet("7","8")
    
            $attribute_collection = New-Object -TypeName "System.Collections.ObjectModel.Collection[System.Attribute]"
            $attribute_collection.Add($CentOSVersion)
    
            $dynamic_parameter = New-Object -TypeName "System.Management.Automation.RuntimeDefinedParameter(`"CentOSVersion`", [string], $attribute_collection)"
            $parameter_dictionary = New-Object -TypeName "System.Management.Automation.RuntimeDefinedParameterDictionary"
            $parameter_dictionary.Add("CentOSVersion", $dynamic_parameter)
            $parameter_dictionary
        }
    }

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
    
}
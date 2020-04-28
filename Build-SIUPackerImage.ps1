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
        #[Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName)]
        #[ValidateSet("HyperV","Vsphere","Virtualbox")]
        #[string] $Hypervisor,
        ##
        [Parameter(Mandatory, Position=1, ValueFromPipeline)]
        [ValidateSet([OperatingSystemValidValues])]
        [string[]] $OSName,
        ##
        [Parameter(Mandatory, Position=2, ValueFromPipelineByPropertyName)]
        [ValidateSet('desktop','server')]
        [string[]] $OSBuildType,
        ##
        [Parameter()]
        [ValidateSet("bios","uefi")]
        [string] $Firmware = "uefi",
        ##
        [Parameter()]
        [ValidateSet("BuildBaseImage","BuildUpdatedBaseImage","CleanupBaseImage")]
        [string] $BuildStep = "BuildBaseImage",
        ##
        [Parameter()]
        [string] $OutputPath = "$PSScriptRoot\builds",
        ##
        [Parameter()]
        [ValidateSet([OperatingSystemArchitectureValidValues])]
        [string[]] $OSArch = "x64"
    )

    DynamicParam {
        if ($OSName -eq 'windows') {

            $param_winversion = "WindowsVersion"
            $param_winsku = "WindowsSKU"
            #$param_winuanttend = "WindowsUnattendFile"
            #WindowsVersion parameter

            $iso_file_names = Get-ChildItem -Path "$PSScriptRoot\iso" | Where-Object { $_.Name -like "$OSName*.iso" }
            $iso_table = [ordered] @{}
            $iso_table_array = @()
            foreach ($file in $iso_file_names) {
                $iso_properties = $file.BaseName -split '-'
                $iso_table = (ConvertFrom-StringData -StringData "OSName = $($iso_properties[0]) `n OSVersion = $($iso_properties[1]) `n OSType = $($iso_properties[2]) `n OSArch = $($iso_properties[3])")
                $iso_table_array += ($iso_table)
            }

            $WindowsVersion = New-Object -TypeName System.Management.Automation.ParameterAttribute
            $WindowsVersion.Mandatory = $true

            $validate_set_attribute = New-Object -TypeName System.Management.Automation.ValidateSetAttribute -ArgumentList $($iso_table_array | Where-Object { $_.OSType -eq $OSBuildType} | Select-Object -ExpandProperty OSVersion)
            $attribute_collection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
            $attribute_collection.Add($WindowsVersion)
            $attribute_collection.Add($validate_set_attribute)
    
            $dynamic_parameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter($param_winversion, [string], $attribute_collection)
            $parameter_dictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
            $parameter_dictionary.Add($param_winversion, $dynamic_parameter)
            
            #WindowsSKU parameter
            $WindowsSKU = New-Object -TypeName System.Management.Automation.ParameterAttribute
            $WindowsSKU.Mandatory = $true

            if ($OSBuildType -eq 'server') {
                $validate_set_attribute = New-Object -TypeName System.Management.Automation.ValidateSetAttribute -ArgumentList 'SERVERSTANDARD','SERVERSTANDARDCORE','SERVERDATACENTER','SERVERDATACENTERCORE'
            }
            elseif ($OSBuildType -eq 'desktop') {
                $validate_set_attribute = New-Object -TypeName System.Management.Automation.ValidateSetAttribute -ArgumentList 'ENTERPRISE','PROFESSIONAL'
            }
            $attribute_collection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
            $attribute_collection.Add($WindowsSKU)
            $attribute_collection.Add($validate_set_attribute)
        
            $dynamic_parameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter($param_winsku, [string], $attribute_collection)
            $parameter_dictionary.Add($param_winsku, $dynamic_parameter)

            return $parameter_dictionary
        }

        elseif ($OSName -eq 'ubuntu') {
            $param_ubuntuversion = "UbuntuVersion"

            $iso_file_names = Get-ChildItem -Path "$PSScriptRoot\iso" | Where-Object { $_.Name -like "$OSName*.iso" }
            $iso_table = [ordered] @{}
            $iso_table_array = @()
            foreach ($file in $iso_file_names) {
                $iso_properties = $file.BaseName -split '-'
                $iso_table = (ConvertFrom-StringData -StringData "OSName = $($iso_properties[0]) `n OSVersion = $($iso_properties[1]) `n OSType = $($iso_properties[2]) `n OSArch = $($iso_properties[3])")
                $iso_table_array += ($iso_table)
            }

            #UbuntuVersion parameter
            $UbuntuVersion = New-Object -TypeName System.Management.Automation.ParameterAttribute
            $UbuntuVersion.Position = 1
            $UbuntuVersion.Mandatory = $true

            $validate_set_attribute = New-Object -TypeName System.Management.Automation.ValidateSetAttribute -ArgumentList $($iso_table_array | Where-Object { $_.OSType -eq $OSBuildType} | Select-Object -ExpandProperty OSVersion)
            $attribute_collection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
            $attribute_collection.Add($UbuntuVersion)
            $attribute_collection.Add($validate_set_attribute)
    
            $dynamic_parameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter($param_ubuntuversion, [string], $attribute_collection)
            $parameter_dictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
            $parameter_dictionary.Add($param_ubuntuversion, $dynamic_parameter)

            return $parameter_dictionary
        }
        elseif ($OSName -eq "centos") {
            $param_centosversion = "CentOSVersion"

            $iso_file_names = Get-ChildItem -Path "$PSScriptRoot\iso" | Where-Object { $_.Name -like "$OSName*.iso" }
            $iso_table = [ordered] @{}
            $iso_table_array = @()
            foreach ($file in $iso_file_names) {
                $iso_properties = $file.BaseName -split '-'
                $iso_table = (ConvertFrom-StringData -StringData "OSName = $($iso_properties[0]) `n OSVersion = $($iso_properties[1]) `n OSType = $($iso_properties[2]) `n OSArch = $($iso_properties[3])")
                $iso_table_array += ($iso_table)
            }

            #CentOSVersion parameter
            $CentOSVersion = New-Object -TypeName System.Management.Automation.ParameterAttribute
            $CentOSVersion.Position = 1
            $CentOSVersion.Mandatory = $true

            $validate_set_attribute = New-Object -TypeName System.Management.Automation.ValidateSetAttribute -ArgumentList $($iso_table_array | Where-Object { $_.OSType -eq 'server'} | Select-Object -ExpandProperty OSVersion)
            $attribute_collection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
            $attribute_collection.Add($CentOSVersion)
            $attribute_collection.Add($validate_set_attribute)
    
            $dynamic_parameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter($param_centosversion, [string], $attribute_collection)
            $parameter_dictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
            $parameter_dictionary.Add($param_centosversion, $dynamic_parameter)
            return $parameter_dictionary
        }
    }

    BEGIN {
        $iso_directory = "$PSScriptRoot\iso"
        Invoke-Expression -Command "$iso_directory\Build-HashSumFile.ps1"
        #Regenerate the iso table
        $iso_file_names = Get-ChildItem -Path "$PSScriptRoot\iso\" | Where-Object { $_.Name -like "windows*.iso" }
        $iso_table = [ordered] @{}
        $iso_table_array = @()
        foreach ($file in $iso_file_names) {
            $iso_properties = $file.BaseName -split '-'
            $iso_table = (ConvertFrom-StringData -StringData "OSName = $($iso_properties[0]) `n OSVersion = $($iso_properties[1]) `n OSType = $($iso_properties[2]) `n OSArch = $($iso_properties[3])")
            $iso_table_array += ($iso_table)
        }
        if ($OSName -eq 'windows') {
            # This is essential for the dynamic parameters to be recognized.
            $WindowsVersionObj = $PSBoundParameters[$param_winversion]
            $WindowsSkuObj = $PSBoundParameters[$param_winsku]
            $CurrentWindowsObject = $iso_table_array | Where-Object { $_.OSVersion -eq $WindowsVersionObj }
        }
        elseif ($OSName -eq 'ubuntu') {
            # This is essential for the dynamic parameters to be recognized.
            $UbuntuVersionObj = $PSBoundParameters[$param_ubuntuversion]
            $CurrentUbuntuObject = $iso_table_array | Where-Object { $_.OSVersion -eq $UbuntuVersionObj }
        }
        elseif ($OSName -eq 'centos') {
            # This is essential for the dynamic parameters to be recognized.
            $CentOSVersionObj = $PSBoundParameters[$param_centosversion]
            $CurrentCentOSObject = $iso_table_array | Where-Object { $_.OSVersion -eq $CentOSVersionObj }

            if ($OSBuildType -eq 'desktop') {
                throw "Desktop deployment not available for CentOS right now. Please use `"server`" for your OSBuildType value."
            }
        }
    }
    
    PROCESS {
        foreach ($os in $OSName) {
            switch ($os) {
        
                'windows' {
                    switch ($WindowsSKUObj) {
                        'SERVERSTANDARD' { $unattend_path = "$PSScriptRoot\windows\unattend\$Firmware\serverstandard\autounattend.xml" }
                        'SERVERDATACENTER' { $unattend_path = "$PSScriptRoot\windows\unattend\$Firmware\serverdatacenter\autounattend.xml" }
                        'SERVERSTANDARDCORE' { $unattend_path = "$PSScriptRoot\windows\unattend\$Firmware\serverstandardcore\autounattend.xml" }
                        'SERVERDATACENTERCORE' { $unattend_path = "$PSScriptRoot\windows\unattend\$Firmware\serverdatacentercore\autounattend.xml" }
                        'ENTERPRISE' { $unattend_path = "$PSScriptRoot\windows\unattend\$Firmware\enterprise\autounattend.xml" }
                        'PROFESSIONAL' { $unattend_path = "$PSScriptRoot\windows\unattend\$Firmware\professional\autounattend.xml" }
                    }
                    
                    $packer_data = [ordered] @{
                        os_name = "$($_)"
                        vm_name = "packer`-$OSName`-$($CurrentWindowsObject.OSVersion)`-$($CurrentWindowsObject.OSType)`-$($CurrentWindowsObject.OSArch)"
                        build_type = "$OSBuildType"
                        iso_url = "$($iso_directory)"
                        unattend_file = "$unattend_path"
                        output_directory = "$OutputPath"
                    }

                    $packer_data
                }
            
                'centos' {
            
                    $packer_data = @{
                        os_name = "$($_)"
                        vm_name = "packer`-$OSName`-$($CurrentCentOSObject.OSVersion)`-$($CurrentCentOSObject.OSType)`-$($CurrentCentOSObject.OSArch)"
                        build_type = "$OSBuildType"
                        iso_url = "$($iso_directory)"
                        kickstart_file = "$unattend_path"
                        output_directory = "$OutputPath"
                    }
                }
            
                'ubuntu' {
            
                    $packer_data = @{
                        os_name = "$($_)"
                        vm_name = "packer`-$OSName`-$($CurrentUbuntuObject.OSVersion)`-$($CurrentUbuntuObject.OSType)`-$($CurrentUbuntuObject.OSArch)"
                        build_type = "$OSBuildType"
                        iso_url = "$($iso_directory)"
                        preseed_file = "$unattend_path"
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
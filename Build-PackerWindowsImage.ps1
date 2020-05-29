#Requires -Version 7
## TODO
## Add flag to disable checksums
## Add custom unattend path

class OperatingSystemArchitectureValidValues : System.Management.Automation.IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $isos = Get-ChildItem -Path "$PSScriptRoot\iso" | Where-Object { $_.Extension -eq ".iso" } | ForEach-Object { $_.BaseName -split '-' }
        $valid_values = @()
        for ($i = 3; $i -lt $isos.Length; $i+=4) {
            $valid_values += $isos[$i]
        }
        return $($valid_values | Sort-Object | Get-Unique)
    }
}

class PackerTemplateFileValidValues : System.Management.Automation.IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $templates = Get-ChildItem -Path "$PSScriptRoot\packer_templates" | Where-Object { $_.Name[0] -ne "." } | Select-Object -ExpandProperty Name
        return $($templates | Sort-Object | Get-Unique)
    }
}

class PackerVariableFileValidValues : System.Management.Automation.IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $templates = Get-ChildItem -Path "$PSScriptRoot\packer_vars" | Where-Object { $_.Name[0] -ne "." } | Select-Object -ExpandProperty Name
        return $($templates | Sort-Object | Get-Unique)
    }
}
function Build-PackerWindowsImage {
    <#
    .SYNOPSIS
        Builds a base Windows image from an ISO utilizing Packer.
    .DESCRIPTION
        Builds a base Windows image from an ISO utilizing Packer.
    .EXAMPLE
        PS C:\> Build-PackerWindowsImage -PackerTemplateFile "/path/to/template.json"
        Builds packer template.json file. Doesn't actually work yet.
    .EXAMPLE
        PS C:\> Build-PackerWindowsImage -OSBuildType desktop -WindowsVersion 1909 -WindowsSKU ENTERPRISE -PackerTemplateFile hyperv_template.json
        Builds an Enterprise Windows image using a Packer Hyper-V template.
    .EXAMPLE
        PS C:\> Build-PackerWindowsImage -OSBuildType server -WindowsVersion 2019 -WindowsSKU SERVERSTANDARD -PackerVariableFile hyperv.gen2_windows_variables1.pkrvars.hcl,hyperv.gen2_windows_variables2.pkrvars.hcl -PackerTemplateFile windows-hyperv.json
        Builds a SERVERSTANDARD Windows image and passes variables from multiple variable files to a Packer Hyper-V template. 
    .EXAMPLE
        PS C:\> Build-PackerWindowsImage -OSBuildType desktop -WindowsVersion 1909 -WindowsSKU ENTERPRISE -PackerVariableFile packer-windows-1909.3.2020-desktop-x64.pkrvars.hcl -OverrideDefaultValues -PackerTemplateFile windows-hyperv.json
        Reuses generated variable file and uses -OverrideDefaultValues to skip setting default values. All variable values are supplied by the variable file.
    .INPUTS
        Inputs (if any)
    .OUTPUTS
        Output (if any)
    .NOTES
        Author: Thomas Aschemann
    #>
    [CmdletBinding()]
    param (

        ##
        [Parameter(Mandatory, Position=0, ParameterSetName="Full")]
        [ValidateSet('desktop','server')]
        [string[]] $OSBuildType,
        ##
        [Parameter(Mandatory, ParameterSetName="Full")]
        [ValidateSet("bios","uefi")]
        [string] $Firmware = "uefi",
        ##
        #[Parameter()]
        #[ValidateSet("BuildBaseImage","BuildUpdatedBaseImage","CleanupBaseImage")]
        #[string] $ImageBuildStep,
        ##
        [Parameter(ParameterSetName="Full")]
        [ValidateSet([OperatingSystemArchitectureValidValues])]
        [string[]] $OSArch = "x64",
        ##
        [Parameter(Mandatory, ParameterSetName="Default")]
        [Parameter(Mandatory, ParameterSetName="PackerTwo")]
        [Parameter(Mandatory, ParameterSetName="PackerThree")]
        [Parameter(Mandatory, ParameterSetName="Full")]
        [ValidateSet([PackerTemplateFileValidValues])]
        [string] $PackerTemplateFile,
        ##
        [Parameter(ParameterSetName="PackerTwo")]
        [Parameter(Mandatory, ParameterSetName="PackerThree")]
        [Parameter(ParameterSetName="Full")]
        [ValidateSet([PackerVariableFileValidValues])]
        [string[]] $PackerVariableFile,
        ##
        [Parameter()]
        [Parameter(ParameterSetName="PackerThree")]
        [switch] $OverrideDefaultValues,
        ##
        [Parameter()]
        [string] $OutputPath = "$PSScriptRoot\builds"
    )
    #region Dynamic Parameters
    DynamicParam {
        if ($true) {
            $param_winversion = "WindowsVersion"
            $param_winsku = "WindowsSKU"

            $iso_file_names = Get-ChildItem -Path "$PSScriptRoot\iso" | Where-Object { $_.Extension -eq ".iso" }
            $iso_table = [ordered] @{}
            $iso_table_array = @()
            foreach ($file in $iso_file_names) {
                $iso_properties = $file.BaseName -split '-'
                $iso_table = (ConvertFrom-StringData -StringData "OSName = $($iso_properties[0]) `n OSVersion = $($iso_properties[1]) `n OSType = $($iso_properties[2]) `n OSArch = $($iso_properties[3])")
                $iso_table_array += ($iso_table)
            }

            #WindowsVersion parameter
            $WindowsVersion = New-Object -TypeName System.Management.Automation.ParameterAttribute
            $WindowsVersion.Mandatory = $true
            $WindowsVersion.ParameterSetName = "Full"

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
            $WindowsSKU.ParameterSetName = "Full"

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

    }
    #endregion Dynamic Parameters
    BEGIN {
        #region Packer Settings
        $packer_root = "$PSScriptRoot"
        $packer_templates = "$packer_root\packer_templates"
        $packer_vars = "$packer_root\packer_vars"
        $env:PACKER_LOG=1
        $env:PACKER_LOG_PATH="$packer_root\logs\packer_windows_$(Get-Date -UFormat "%d%b%Y_%H%M%S").log"
        if (-not (Test-Path "$packer_root\logs")) {
            New-Item -Path "$packer_root\logs" -ItemType Directory -Force
        }
        #endregion Packer Settings

        Start-Transcript -Path "$packer_root\logs\Build-PackerImage_$(Get-Date -UFormat "%d%b%Y_%H%M%S").log" -IncludeInvocationHeader
        #region HTTP Paths
        $local_http_directory = "$packer_root\http"
        $iso_local_directory = "$packer_root\iso"
        $iso_checksum_local_directory = "$iso_local_directory\checksums"
        #endregion HTTP Paths
        
        Invoke-Expression -Command "$iso_local_directory\Build-HashSumFile.ps1"
        #Regenerate the iso table
        $iso_file_names = Get-ChildItem -Path "$iso_local_directory" | Where-Object { $_.Extension -eq ".iso" } | Select-Object -Property "BaseName"
        $iso_table = [ordered] @{}
        $iso_table_array = @()
        foreach ($file in $iso_file_names) {
            $iso_properties = $file.BaseName -split '-'
            $iso_table = (ConvertFrom-StringData -StringData "OSName = $($iso_properties[0]) `n OSVersion = $($iso_properties[1]) `n OSType = $($iso_properties[2]) `n OSArch = $($iso_properties[3])")
            $iso_table_array += ($iso_table)
        }
    }
    
    PROCESS {
        # This is essential for the dynamic parameters to be recognized.
        $OSVersionObj = $PSBoundParameters[$param_winversion]
        $WindowsSkuObj = $PSBoundParameters[$param_winsku]
        $CurrentOSObj = $iso_table_array | Where-Object { ($_.OSVersion -eq $OSVersionObj) -and ($_.OSType -eq $OSBuildType) -and ($_.OSArch -eq $OSArch) }

        $current_iso_name = Get-ChildItem -Path "$iso_local_directory" | Where-Object { $_.Name -eq "windows-$OSVersionObj-$OSBuildType-$OSArch.iso" } | Select-Object -ExpandProperty Name
        $current_iso_checksum = Get-ChildItem -Path "$iso_checksum_local_directory" | Where-Object { $_.Name -eq "windows-$OSVersionObj-$OSBuildType-$OSArch`_checksum.txt" } | Select-Object -ExpandProperty Name
            
        #There will only ever be one Packer template. This line grabs the template file the user
        #selected and pulls the variable section out of it so we can then set any values here.
        $packer_data = Get-Content -Path "$packer_templates\$PackerTemplateFile" | ConvertFrom-Json -AsHashtable | Select-Object -ExpandProperty variables
        $packer_data_keys = @("os_name","vm_name","os_build_type","iso_url","iso_checksum","iso_checksum_type","unattend_file","output_directory","firmware","http_directory","secondary_iso_images")
        foreach ($key in $packer_data_keys) {
            if ($key -notin $packer_data.Keys) {
                $packer_data.Add("$key", '""')
            }
        }
            
        #Loop through variables files and merge all the variable tables together, then merge that with what's in $packer_data
        foreach ($file in $PackerVariableFile) {
            $packer_varfile = Get-Content -Path "$packer_vars\$file" | ConvertFrom-Json -AsHashtable

            foreach ($var in $packer_varfile.Keys) {
                if ($var -notin $packer_data.Keys) {
                    $packer_data.Add($var, $packer_varfile[$var])
                }
                else {
                    if (($null -eq $packer_varfile[$var]) -or ($packer_varfile[$var] -eq '""')) {
                        Write-Output "$var is null or empty in $file. Not overriding set value."
                    }
                    else {
                        $packer_data[$var] = $packer_varfile[$var]
                    }
                }
            }
        }
            
        #If the user doesn't specify the override parameter, set these values as default no matter the configuration
        if (-not($OverrideDefaultValues)) {
            $packer_data["os_name"] = "windows"
            $packer_data["vm_name"] = "packer-windows-$($CurrentOSObj.OSVersion)-$($CurrentOSObj.OSType)-$($CurrentOSObj.OSArch)-$($WindowsSkuObj)"
            $packer_data["os_build_type"] = "$OSBuildType"
            $packer_data["iso_url"] = "$iso_local_directory\$current_iso_name"
            $packer_data["iso_checksum"] = "$iso_checksum_local_directory\$current_iso_checksum"
            $packer_data["iso_checksum_type"] = "file"
            $packer_data["output_directory"] = "$OutputPath\build_cache"
            $packer_data["firmware"] = "$Firmware"
            $packer_data["http_directory"] = "$local_http_directory"
            $packer_data["unattend_file"] = "$packer_root\unattend\$Firmware\$OSBuildType\$($CurrentOSObj.OSVersion)\$WindowsSkuObj\autounattend.xml"
            $packer_data["secondary_iso_images"] = "$packer_root\unattend\$Firmware\$OSBuildType\$($CurrentOSObj.OSVersion)\$WindowsSkuObj\answer.iso"
        }
        else {
            Write-Output "All variable values being written from variable file. Not setting variables."
        }

        if (-not (Test-Path "$packer_vars\$($packer_data.vm_name).pkrvars.hcl")) {
            New-Item -Path "$packer_vars\$($packer_data.vm_name).pkrvars.hcl" -ItemType File
        }

        Clear-Content -Path "$packer_vars\$($packer_data.vm_name).pkrvars.hcl"
        $packer_data | ConvertTo-Json -Depth 3 | Add-Content -Path "$packer_vars/$($packer_data.vm_name).pkrvars.hcl"

        $packer_data | Sort-Object $_.Name
        ########################################################
        # Run the build in multiple steps to prevent loss of time in case a build fails somewhere in the middle.
        ########################################################
        switch ($BuildStep) {

            "BuildBaseImage" {
                ########################################################
                # Build Base Image
                ########################################################
                foreach ($varfile in $PackerVariableFile) {
                    if ($template -match $varfile) {
                        $var_file_array += @($template | ForEach-Object {"-var-file `"$_`""} )
                    }
                }

                Write-Verbose -Message "Starting process: $(Get-ChildItem -Path $packer_root | Where-Object { $_.Extension -eq ".exe" }) build $var_file_array -var-file `"$packer_vars\$($packer_data.vm_name).pkrvars.hcl`" -force $packer_templates\$PackerTemplateFile"
                Start-Process -FilePath "$(Get-ChildItem -Path $packer_root | Where-Object { $_.Extension -eq ".exe" } )" -ArgumentList "build $var_file_array -var-file `"$packer_vars\$($packer_data.vm_name).pkrvars.hcl`" -force $packer_templates\$PackerTemplateFile" -Wait -NoNewWindow 
            }

            "BuildUpdatedBaseImage" { 
                ########################################################
                # Build Image with Updates
                ########################################################
                $templates = Get-ChildItem -Path "$packer_root\shared\packer_vars" | Where-Object { ($_.Extension -eq ".hcl") -and ($_.Name[0] -ne '.') } | Select-Object -ExpandProperty FullName
                foreach ($template in $templates) {
                    foreach ($varfile in $PackerVariableFile) {
                        if ($template -match $varfile) {
                            $var_file_array += @($template | ForEach-Object {"-var-file `"$_`""} )
                        }
                    }
                }

                Write-Verbose -Message "Starting process: $(Get-ChildItem -Path $packer_root | Where-Object { $_.Extension -eq ".exe" }) build -var-file $packer_vars\hyperv.gen2_$($OSName)_variables.pkrvars.hcl -var-file $packer_vars/$($packer_data.vm_name).pkrvars.hcl -force $packer_templates\$PackerTemplateFile"
                Start-Process -FilePath "$(Get-ChildItem -Path $packer_root | Where-Object { $_.Extension -eq ".exe" } )" -ArgumentList "build $var_file_array -var-file `"$packer_root\$($packer_data.vm_name).pkrvars.hcl`" -force $packer_templates\$PackerTemplateFile" -Wait -NoNewWindow 
            }

            "CleanupBaseImage" { 
                ########################################################
                # Cleanup Updated Image
                ########################################################
                $templates = Get-ChildItem -Path ".\shared\packer_vars" | Where-Object { ($_.Extension -eq ".hcl") -and ($_.Name[0] -ne '.') } | Select-Object -ExpandProperty FullName
                foreach ($template in $templates) {
                    foreach ($varfile in $PackerVariableFile) {
                        if ($template -match $varfile) {
                            $var_file_array += @($template | ForEach-Object {"-var-file `"$_`""} )
                        }
                    }
                }

                Write-Verbose -Message "Starting process: $(Get-ChildItem -Path $packer_root | Where-Object { $_.Extension -eq ".exe" }) build -var-file $packer_vars\hyperv.gen2_$($OSName)_variables.pkrvars.hcl -var-file $packer_vars/$($packer_data.vm_name).pkrvars.hcl -force $packer_templates\$PackerTemplateFile"
                Start-Process -FilePath "$(Get-ChildItem -Path $packer_root | Where-Object { $_.Extension -eq ".exe" } )" -ArgumentList "build $var_file_array -var-file `"$packer_root\$($packer_data.vm_name).pkrvars.hcl`" -force $packer_templates\$PackerTemplateFile" -Wait -NoNewWindow 
            }
            Default { 
                # Build Specified Configuration

                Write-Verbose -Message "Starting process: $(Get-ChildItem -Path $packer_root | Where-Object { $_.Extension -eq ".exe" }) -ArgumentList build $($var_file_array -join ' ') -force $packer_templates\$PackerTemplateFile"
                Start-Process -FilePath "$(Get-ChildItem -Path $packer_root | Where-Object { $_.Extension -eq ".exe" } | Select-Object -Last 1)" -ArgumentList "build -var-file $packer_vars\$($packer_data.vm_name).pkrvars.hcl -force $packer_templates\$PackerTemplateFile" -Wait -NoNewWindow 
            }
        }
    }
    
    END {
        Stop-Transcript
    }
    
}
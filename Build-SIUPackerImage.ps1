#Requires -Version 7

class OperatingSystemValidValues : System.Management.Automation.IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $isos = Get-ChildItem -Path "$PSScriptRoot\shared\http\iso" | Where-Object { $_.Extension -eq ".iso" } | ForEach-Object { $_.BaseName -split '-' }
        $valid_values = @()
        for ($i = 0; $i -lt $isos.Length; $i+=4) {
            $valid_values += $isos[$i]
        }
        return $($valid_values | Sort-Object | Get-Unique)
    }
}

class OperatingSystemArchitectureValidValues : System.Management.Automation.IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $isos = Get-ChildItem -Path "$PSScriptRoot\shared\http\iso" | Where-Object { $_.Extension -eq ".iso" } | ForEach-Object { $_.BaseName -split '-' }
        $valid_values = @()
        for ($i = 3; $i -lt $isos.Length; $i+=4) {
            $valid_values += $isos[$i]
        }
        return $($valid_values | Sort-Object | Get-Unique)
    }
}

class PackerTemplatesValidValues : System.Management.Automation.IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $templates = Get-ChildItem -Path "$PSScriptRoot\shared\utils\packer\packer_templates" | Where-Object { ($_.Extension -eq ".json") -and ($_.Name[0] -ne '.') } | Select-Object -ExpandProperty Name
        return $($templates | Sort-Object | Get-Unique)
    }
}

class PackerVariableFilesValidValues : System.Management.Automation.IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        $templates = Get-ChildItem -Path "$PSScriptRoot\shared\utils\packer\packer_vars" | Where-Object { ($_.Extension -eq ".hcl") -and ($_.Name[0] -ne '.') } | Select-Object -ExpandProperty Name
        return $($templates | Sort-Object | Get-Unique)
    }
}

function Build-SIUPackerImage {
    [CmdletBinding()]
    param (
        ##
        [Parameter(Mandatory, Position=0, ValueFromPipeline)]
        [ValidateSet([OperatingSystemValidValues])]
        [string[]] $OSName,
        ##
        [Parameter(Mandatory, Position=1, ValueFromPipelineByPropertyName)]
        [ValidateSet('desktop','server')]
        [string[]] $OSBuildType,
        ##
        [Parameter()]
        [ValidateSet("bios","uefi")]
        [string] $Firmware = "uefi",
        ##
        [Parameter(Mandatory)]
        [ValidateSet([PackerTemplatesValidValues])]
        [string] $PackerTemplateFile,
        ##
        [Parameter()]
        [ValidateSet([PackerVariableFilesValidValues])]
        [string[]] $PackerVariableFile,
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
    #region Dynamic Parameters
    DynamicParam {
        if ($OSName -eq 'windows') {

            $param_winversion = "WindowsVersion"
            $param_winsku = "WindowsSKU"
            #$param_winuanttend = "WindowsUnattendFile"
            #WindowsVersion parameter

            $iso_file_names = Get-ChildItem -Path "$PSScriptRoot\shared\http\iso" | Where-Object { $_.Name -like "$OSName*.iso" }
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

            $iso_file_names = Get-ChildItem -Path "$PSScriptRoot\shared\http\iso" | Where-Object { $_.Name -like "$OSName*.iso" }
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

            $iso_file_names = Get-ChildItem -Path "$PSScriptRoot\shared\http\iso" | Where-Object { $_.Name -like "$OSName*.iso" }
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
    #endregion Dynamic Parameters
    BEGIN {
        #region Packer Settings
        $packer_root = "$PSScriptRoot\shared\utils\packer"
        $packer_templates = "$packer_root\packer_templates"
        $packer_vars = "$packer_root\packer_vars"
        $packer_http_path = '"{{ .HTTPIP }}":"{{ .HTTPPort }}"'
        $env:PACKER_LOG=1
        $env:PACKER_LOG_PATH="$PSScriptRoot\logs\packer_$OSName_$(Get-Date -UFormat "%d%b%Y_%H%M%S").log"
        if (-not (Test-Path "$PSScriptRoot\logs")) {
            New-Item -Path "$PSScriptRoot\logs" -ItemType Directory -Force
        }
        #endregion Packer Settings

        Start-Transcript -Path "$PSScriptRoot\logs\Build-SIUPackerImage_$(Get-Date -UFormat "%d%b%Y_%H%M%S").log" -IncludeInvocationHeader
        #region HTTP Paths
        $local_http_directory = "$PSScriptRoot\shared\http"
        $iso_local_directory = "$local_http_directory\iso"
        $iso_checksum_local_directory = "$iso_local_directory\checksums"
        $iso_http_path = "$packer_http_path/iso"
        $iso_checksum_http_path = "$iso_http_path/checksums"
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
        foreach ($os in $OSName) {
            if ($os -eq 'windows') {
                # This is essential for the dynamic parameters to be recognized.
                $OSVersionObj = $PSBoundParameters[$param_winversion]
                $WindowsSkuObj = $PSBoundParameters[$param_winsku]
                $CurrentOSObj = $iso_table_array | Where-Object { $_.OSVersion -eq $OSVersionObj }
            }
            elseif ($os -eq 'centos') {
                # This is essential for the dynamic parameters to be recognized.
                $OSVersionObj = $PSBoundParameters[$param_centosversion]
                $CurrentOSObj = $iso_table_array | Where-Object { $_.OSVersion -eq $OSVersionObj }
    
                if ($OSBuildType -eq 'desktop') {
                    throw "Desktop deployment not available for CentOS right now. Please use `"server`" for your OSBuildType value."
                }
            }
            elseif ($os -eq 'ubuntu') {
                # This is essential for the dynamic parameters to be recognized.
                $OSVersionObj = $PSBoundParameters[$param_ubuntuversion]
                $CurrentOSObj = $iso_table_array | Where-Object { $_.OSVersion -eq $OSVersionObj }            
            }

            $current_iso_name = Get-ChildItem -Path "$PSScriptRoot\shared\http\iso" | Where-Object { $_.Name -like "$os*$OSVersionObj*.iso" } | Select-Object -ExpandProperty Name
            $current_iso_checksum = Get-ChildItem -Path "$PSScriptRoot\shared\http\iso\checksums" | Where-Object { $_.Name -like "$os*$OSVersionObj*.txt" } | Select-Object -ExpandProperty Name
            
            $packer_data = Get-Content -Path $PackerTemplateFile | ConvertFrom-Json -AsHashtable | Select-Object -ExpandProperty variables
            $packer_data.os_name = "$os"
            $packer_data.vm_name = "packer-$os-$($CurrentOSObj.OSVersion)-$($CurrentOSObj.OSType)-$($CurrentOSObj.OSArch)"
            $packer_data.os_build_type = "$OSBuildType"
            $packer_data.iso_url = "$iso_local_directory\$current_iso_name"
            $packer_data.iso_checksum = "$iso_checksum_local_directory\$current_iso_checksum"
            $packer_data.iso_checksum_type = "file"
            $packer_data.unattend_file = "$PSScriptRoot\windows\unattend\$Firmware\$WindowsSkuObj\autounattend.xml"
            $packer_data.output_directory = "$OutputPath\packer`-$os`-$($CurrentOSObj.OSVersion)`-$($CurrentOSObj.OSType)`-$($CurrentOSObj.OSArch)"
            $packer_data.firmware = "$Firmware"
            $packer_data.http_directory = "$local_http_directory"

            if (-not (Test-Path "$packer_vars\$($packer_data.vm_name).pkrvars.hcl")) {
                New-Item -Path "$packer_vars\$($packer_data.vm_name).pkrvars.hcl" -ItemType File
            }

            Clear-Content -Path "$packer_vars\$($packer_data.vm_name).pkrvars.hcl" -ErrorAction SilentlyContinue
            #$packer_data | ConvertTo-Json -Depth 3 | Add-Content -Path "$packer_root/$($packer_data.vm_name).pkrvars.hcl"

            
            # Run the build in multiple steps to prevent loss of time in case a build fails somewhere in the middle.
            switch ($BuildStep) {

                "BuildBaseImage" { 
                    # Build Base Image
                    $templates = Get-ChildItem -Path ".\shared\utils\packer\packer_vars" | Where-Object { ($_.Extension -eq ".hcl") -and ($_.Name[0] -ne '.') } | Select-Object -ExpandProperty FullName
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

                "BuildUpdatedBaseImage" { 
                    # Build Image with Updates
                    $templates = Get-ChildItem -Path "$PSScriptRoot\shared\utils\packer\packer_vars" | Where-Object { ($_.Extension -eq ".hcl") -and ($_.Name[0] -ne '.') } | Select-Object -ExpandProperty FullName
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
                    # Cleanup Updated Image
                    $templates = Get-ChildItem -Path ".\shared\utils\packer\packer_vars" | Where-Object { ($_.Extension -eq ".hcl") -and ($_.Name[0] -ne '.') } | Select-Object -ExpandProperty FullName
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
                Default {  }
            }
        }
    }
    
    END {
        Stop-Transcript
    }
    
}
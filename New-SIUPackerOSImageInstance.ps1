
function New-SIUPackerOSImageInstance {
    [CmdletBinding()]
    param (
        ##
        [Parameter(Mandatory)]
        [ValidateSet("windows","centos","ubuntu")]
        [string] $OSName,
        ##
        [Parameter(Mandatory)]
        [ValidateSet("desktop","server")]
        [string] $BuildType,
        ##
        [Parameter(Mandatory)]
        [string[]] $IsoPath
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
        if ($OSName -eq 'windows') {
            # This is essential for the dynamic parameters to be recognized.
            $WindowsVersionObj = $PSBoundParameters[$param_winversion]
            $WindowsSkuObj = $PSBoundParameters[$param_winsku]   
            $WindowsUnattendObj = $PSBoundParameters[$param_winuanttend]
        }
        elseif ($OSName -eq 'ubuntu') {
            # This is essential for the dynamic parameters to be recognized.
            $UbuntuVersionObj = $PSBoundParameters[$param_ubuntuversion]         
        }
    }

    PROCESS {
        switch ($OSName) {
            "windows" {
                return $os_instance = @{
                    os_name = "$($_)"
                    os_sku = $WindowsSkuObj
                    os_buildtype = $BuildType
                    os_version = $WindowsVersionObj
                    iso_url = $IsoPath
                    unattend_file = $WindowsUnattendObj
                }
            }
        
            "centos" { 
        
            }
        
            "ubuntu" { 
                return $os_instance = @{
                    os_name = "$($_)"
                    os_buildtype = $BuildType
                    os_version = $UbuntuVersionObj
                    iso_url = $IsoPath
                }
            }
        }
    }
    END {}
}
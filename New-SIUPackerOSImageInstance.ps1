
function New-SIUPackerOSImageInstance {
    [CmdletBinding()]
    param (
        ##
        [Parameter(Mandatory)]
        [ValidateSet("windows","centos","ubuntu")]
        [string] $OSName,
        ##
        [ValidateSet("desktop","server")]
        [string] $BuildType
        ##
    )

    DynamicParam {
        if ($OSName -eq 'windows') {
            if ($BuildType -eq 'server') {

                $param_winversion = "WindowsVersion"
                $param_winsku = "WindowsSKU"

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
    
                $validate_set_attribute = New-Object -TypeName System.Management.Automation.ValidateSetAttribute -ArgumentList 'SERVERSTANDARD','SERVERSTANDARDCORE'
                $attribute_collection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
                $attribute_collection.Add($WindowsSKU)
                $attribute_collection.Add($validate_set_attribute)
        
                $dynamic_parameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter($param_winsku, [string], $attribute_collection)
                $parameter_dictionary.Add($param_winsku, $dynamic_parameter)
                return $parameter_dictionary
            }
            
            elseif ($BuildType -eq 'desktop') {
                $param_winversion = "WindowsVersion"
                $param_winsku = "WindowsSKU"

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
                return $parameter_dictionary
            }
        }
<#         elseif ($OSName -eq 'ubuntu') {
            $UbuntuVersion = New-Object -TypeName "System.Management.Automation.ParameterAttribute"
            $UbuntuVersion.ParameterSetName = "Ubuntu"
            $UbuntuVersion.Mandatory = $true
    
            $attribute_collection = New-Object -TypeName "System.Collections.ObjectModel.Collection[System.Attribute]"
            $attribute_collection.Add($UbuntuVersion)
    
            $dynamic_parameter = New-Object -TypeName "System.Management.Automation.RuntimeDefinedParameter(`"UbuntuVersion`", [string], $attribute_collection)"
            $parameter_dictionary = New-Object -TypeName "System.Management.Automation.RuntimeDefinedParameterDictionary"
            $parameter_dictionary.Add("UbuntuVersion", $dynamic_parameter)
            $parameter_dictionary
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
        } #>
    }
    
    BEGIN {
        # This is essential for the dynamic parameters to be recognized.
        $WindowsVersionObj = $PSBoundParameters[$param_winversion]
        $WindowsSkuObj = $PSBoundParameters[$param_winsku]
    }

    PROCESS {
        switch ($OSName) {
            "windows" {
                return $os_instance = @{
                    os_name = "$($_)"
                    os_sku = $WindowsSkuObj
                    os_buildtype = $BuildType
                    os_version = $WindowsVersionObj
                }
            }
        
            "centos" { 
        
            }
        
            "ubuntu" { 
        
            }
        }
    }
    END {}
}

function New-SIUPackerOSImageInstance {
    [CmdletBinding()]
    param (
        ##
        [Parameter(Mandatory)]
        [ValidateSet("windows","centos","ubuntu")]
        [string] $OSName,
        ##
        [ValidateSet("desktop","server")]
        [string] $BuildType,
        ##
        [Parameter(ParameterSetName="Windows")]
        [ValidateSet("SERVERSTANDARD","SERVERSTANDARDCORE","SERVERDATACENTER","SERVERDATACENTERCORE","ENTERPRISE","PROFESSIONAL")]
        [string] $WindowsSKU,
        ##
        [Parameter()]
        [string] $VMName
    )

    DynamicParam {
        if ($OSName -eq 'windows') {
            $parameter_name = "WindowsVersion"

            $WindowsVersion = New-Object -TypeName System.Management.Automation.ParameterAttribute
            $WindowsVersion.Position = 1
            $WindowsVersion.Mandatory = $true

            $validate_set_attribute = New-Object -TypeName System.Management.Automation.ValidateSetAttribute -ArgumentList '2016','2019'
            $attribute_collection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
            $attribute_collection.Add($WindowsVersion)
            $attribute_collection.Add($validate_set_attribute)
    
            $dynamic_parameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter($parameter_name, [string], $attribute_collection)
            $parameter_dictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
            $parameter_dictionary.Add($parameter_name, $dynamic_parameter)
            return $parameter_dictionary
        }
        elseif ($OSName -eq 'ubuntu') {
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
        }
    }
    
    BEGIN {
        $WindowsVersionObj = $PSBoundParameters[$parameter_name]
        $WindowsVersionObj
    }

    PROCESS {
        switch ($OSName) {
            "windows" {
                return $os_instance = @{
                    os_name = "$($_)"
                    os_sku = $WindowsSKU
                    os_buildtype = $BuildType
                    vm_name = { if ($null -eq $VMName) { $VMName = "packer_$($_)_$(Get-Date -UFormat "%d%b%Y_%H%M")" } else {  } }
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
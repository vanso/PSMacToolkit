
function Get-SPLocalizedString
{
    <#
    
    .SYNOPSIS
    Gets a localized string for system_profiler.

    #>
    
    param(
        [String]$String,
        [string]$DataType,
        [string]$Language,
        [switch]$PascalCase
    )

    $localizedString = [SPLocalization]::LocalizedString($String, $DataType, $Language)

    if ($PSBoundParameters.ContainsKey("PascalCase"))
    {
        ConvertTo-PascalCase $localizedString
    }
    else 
    {
        $localizedString
    }
}


function SPRewriteName
{
    param(
        $name,
        $dataType,
        $language,
        $level
    )

    if ([SPSettings]::Raw)
    {
        return $name
    }
   
    $prefix = $dataType -replace "DataType", ""

    $localizedString = $(Get-SPLocalizedString $name $dataType $([SPSettings]::Language))

    ($localizedString.Contains("_")) ? $localizedString -replace $prefix,"" : $(ConvertTo-PascalCase $localizedString) -replace $prefix, ""
    
}

function SPRewriteValue 
{
    param (
        $name,
        $value,
        $dataType,
        $language
    )

    if ([SPSettings]::Raw)
    {
        return $value
    }

    ($value -is [string]) ? $(return Get-SPLocalizedString $value $dataType $language) : $(return $value)
}

function Add-SPTransformedMember 
{
    param(
        [psobject]$TargetObject,
        [string]$Name,
        [object]$Value,
        [string]$DataType,
        [string]$Language
    )

    if (-Not ($Name.StartsWith("_")) -or ( @("_name", "_items") -contains $Name))
    {

    if ($Value -is [array]) 
    {                
        if ($Value.Length -gt 0 -and @([int], [int64], [string]) -contains $Value[0].GetType()) 
        { 
            $TargetObject | Add-Member -MemberType NoteProperty -Name $(SPRewriteName $Name $DataType $Language 0) -Value $(SPRewriteValue $Name $Value $DataType $Language) -Force
        }
        else 
        {
            $processedArray = foreach ($item in $Value)
            {
                $arrayObject = [PSCustomObject]@{}

                foreach ($property in $item.PSObject.Properties) 
                {
                    $localizedName = $(SPRewriteName $property.Name $DataType $Language 1)

                    if ($localizedName -eq "Items" -and [SPSettings]::ResolveItemsName)
                    {
                        $resolvedItem = $($item.PSObject.Properties['_name'].Value)
                        $localizedName = Get-SPLocalizedString $resolvedItem $DataType $Language -PascalCase
                    }

                    Add-SPTransformedMember -TargetObject $arrayObject -Name $localizedName -Value $(SPRewriteValue $property.Name $property.Value $DataType $Language) -Force
                }
            
                $arrayObject
            }

            $localizedName = $(SPRewriteName $Name $DataType $Language  2)

            if ($localizedName -eq "Items" -and [SPSettings]::ResolveItemsName)
            {
                $localizedName = $(Get-SPLocalizedString "_name" $dataType $language -PascalCase)
            }

            $TargetObject | Add-Member -MemberType NoteProperty -Name $localizedName -Value $processedArray -Force
        }
    }
    elseif ($Value -is [PSCustomObject]) 
    {      
        $customObject = [PSCustomObject]@{}

        foreach ($property in $Value.PSObject.Properties) 
        {
            Add-SPTransformedMember -TargetObject $customObject -Name $(SPRewriteName $property.Name $DataType $Language 3) -Value $(SPRewriteValue $property.Name $property.Value $DataType $Language) -Force
        }

        $localizedName = $(SPRewriteName $Name $DataType $Language 4)

        if ($localizedName -eq "Items")
        {
            $localizedName = ConvertTo-PascalCase $localizedName
        }

        $TargetObject | Add-Member -MemberType NoteProperty -Name $localizedName -Value $customObject -Force
       
    }
    else 
    {        
        $key = $(SPRewriteName $name $dataType $Language)
        $localizedValue = $(SPRewriteValue $Name $Value $DataType $Language)

        $TargetObject | Add-Member -MemberType NoteProperty -Name $key -Value $localizedValue -Force 
    }

    }
}


function Get-SPAvailableDataTypes 
{
    <#
    
    .SYNOPSIS
    Lists the available datatypes for Get-SystemInformation.

    #>
    
    [SPSettings]::ListDataTypes()
}


function Get-SPAvailableLocalizations 
{
    <#
    
    .SYNOPSIS
    Lists the available localizations for Get-SystemInformation.

    #>
    
    [SPSettings]::ListAvailableLocalizations()
}

function Get-SystemInformation
{
    <#
    
    .SYNOPSIS
    Reports system hardware and software configuration.

    #>

    [CmdletBinding(DefaultParameterSetName = "DataTypes")]
    param(
        [Parameter(ParameterSetName = "ListDataTypes")]
        [Switch]$ListDataTypes,
        [Parameter(ParameterSetName = "DataTypes", Position = 0)]
        [Parameter(ParameterSetName = "Raw", Position = 0)]
        [Parameter(ParameterSetName = "Fast", Position = 0)]
        [ValidateScript({ $(Get-SPAvailableDataTypes) -ccontains $_}, ErrorMessage = "SPDataType for {0} is not available in Get-SPAvailableDataTypes" )]
        [ArgumentCompletions({ $(Get-SPAvailableDataTypes) })]
        [string[]]$DataTypes = $([SPSettings]::ListDataTypes()),
        [Parameter(ParameterSetName = "DataTypes")]
        [Parameter(ParameterSetName = "Raw")]
        [ValidateScript({$(Get-SPAvailableDataTypes) -ccontains $_ }, ErrorMessage = "SPDataType for {0} is not available in {1} Get-SPAvailableDataTypes" )]
        [ArgumentCompletions({ $(Get-SPAvailableDataTypes) })]
        [string[]]$ExcludeDataTypes,
        [Parameter(ParameterSetName = "DataTypes")]
        [Parameter(ParameterSetName = "Raw")]
        [Parameter(ParameterSetName = "Fast")]
        [ValidateSet("Mini", "Basic", "Full")]
        [string]$DetailLevel = "Full",
        [Parameter(ParameterSetName = "DataTypes")]
        [Parameter(ParameterSetName = "Fast")]
        [ValidateScript({ $(Get-SPAvailableLocalizations) -ccontains $_ }, ErrorMessage = "Localization for {0} is not available in {1} Get-SPAvailableLocalizations" )]
        [ArgumentCompletions({ $(Get-SPAvailableLocalizations) })]
        [string]$Language = "en",
        [Parameter(ParameterSetName = "DataTypes")]
        [Parameter(ParameterSetName = "Raw")]
        [Parameter(ParameterSetName = "Fast")]
        [switch]$Extended,
        [Parameter(ParameterSetName = "DataTypes")]
        [Parameter(ParameterSetName = "Raw")]
        [Parameter(ParameterSetName = "Fast")]
        [switch]$Raw,
        [Parameter(ParameterSetName = "DataTypes")]
        [Parameter(ParameterSetName = "Raw")]
        [Parameter(ParameterSetName = "Fast")]
        [ValidateRange(0,180)]
        [int]$Timeout = 180,
        [Parameter(ParameterSetName = "DataTypes")]
        [Parameter(ParameterSetName = "Fast")]
        [switch]$ResolveItemsName,
        [Parameter(ParameterSetName = "DataTypes")]
        [Parameter(ParameterSetName = "Raw")]
        [Parameter(ParameterSetName = "Fast")]
        [switch]$Fast
    )

    if ($Fast)
    {
        $ExcludeDataTypes = @("SPExtensionsDataType", "SPFontsDataType", "SPDiagnosticsDataType", "SPApplicationsDataType", "SPFrameworksDataType", "SPInstallHistoryDataType", "SPPrefPaneDataType", "SPLogsDataType", "SPRawCameraDataType", "SPSyncServicesDataType", "SPManagedClientDataType", "SPPrefPaneDataType", "SPConfigurationProfileDataType")
    }

    if ($ExcludeDataTypes)
    {
        $DataTypes = [Linq.Enumerable]::Except($DataTypes, $ExcludeDataTypes)
    }

    if ($Language)
    {
        [SPSettings]::CustomLanguage = $Language

        [SPSettings]::FallbackLanguage = [Globalization.CultureInfo]::new($Language).EnglishName
    }

    if ($ResolveItemsName)
    {
        [SPSettings]::ResolveItemsName = $ResolveItemsName
    }

    if ($Raw)
    {
        [SPSettings]::Raw = $true
    }

    if ($PSCmdlet.ParameterSetName -eq "ListDataTypes")
    {
        return $([SPSettings]::ListDataTypes())
    }

    foreach ($dataType in $dataTypes) 
    {
        [SPSettings]::DataType = $dataType
        
        Write-Progress -Activity "Processing DataType: $dataType"

        $jsonOutput = /usr/sbin/system_profiler -json $dataType -detailLevel $($DetailLevel.ToLower()) -Timeout $Timeout

        $checkJsonOutput = $jsonOutput | ConvertFrom-Json | Select-Object -ExpandProperty $dataType

        if (-Not ($checkJsonOutput))
        {
            Write-Verbose "$(Get-SPLocalizedString "no_info_found" $dataType $language) ($dataType)"
        }

      # Process JSON data into a custom PSObject
        $jsonOutput | ConvertFrom-Json | Select-Object -ExpandProperty $dataType | ForEach-Object {
        
            # Create the root object for this data type

            if ($dataType -eq "SPSecureElementDataType")
            {
                $content = $_.PSObject.Properties

                $SPSecureElementDataType = @"
[
    {
      "se_info" : {
        "se_plt" : "$($content['se_plt'].Value)",
        "se_id" : "$($content['se_id'].Value)",
        "se_os_id" : "$($content['se_os_id'].Value)",
        "se_device" : "$($content['se_device'].Value)",
        "se_prod_signed" : "$($content['se_prod_signed'].Value)",
        "se_in_restricted_mode" : "$($content['se_in_restricted_mode'].Value)",
        "se_hw" : "$($content['se_hw'].Value)",
        "se_fw" : "$($content['se_fw'].Value)",
        "se_os_version" : "$($content['se_os_version'].Value)"
      },
      "ctl_info" : {
        "ctl_hw" : "$($content['ctl_hw'].Value)",
        "ctl_fw" : "$($content['ctl_fw'].Value)",
        "ctl_mw" : "$($content['ctl_mw'].Value)"
      }
    }
]
"@
                $properties = ($SPSecureElementDataType | ConvertFrom-Json).PSObject.Properties
            }
            elseif ($dataType -eq "SPiBridgeDataType")
            {
                $content = $_.PSObject.Properties

                $SPiBridgeDataType = @"
[
    {
        "ibridge_boot_uuid" : "$($content['ibridge_boot_uuid'].Value)",
        "ibridge_build" : "$($content['ibridge_build'].Value)",
        "ibridge_model_identifier_top" : "$($content['ibridge_model_identifier_top'].Value)",
        "ibridge_extra_boot_policies" : {
        "ibridge_secure_boot" : "$($content['ibridge_secure_boot'].Value)",
        "ibridge_sb_sip" : "$($content['ibridge_sb_sip'].Value)",
        "ibridge_sb_ssv" : "$($content['ibridge_sb_ssv'].Value)",
        "ibridge_sb_ctrr" : "$($content['ibridge_sb_ctrr'].Value)",
        "ibridge_sb_boot_args" : "$($content['ibridge_sb_boot_args'].Value)",
        "ibridge_sb_other_kext" : "$($content['ibridge_sb_other_kext'].Value)",
        "ibridge_sb_manual_mdm" : "$($content['ibridge_sb_manual_mdm'].Value)",
        "ibridge_sb_device_mdm" : "$($content['ibridge_sb_device_mdm'].Value)"
        }
    }
]
"@
            $properties = ($SPiBridgeDataType | ConvertFrom-Json).PSObject.Properties
            }
            else
            {
                $properties = $_.PSObject.Properties
            }

            $type = Get-SPLocalizedString $dataType $dataType $([SPSettings]::CustomLanguage)

            $rootObject = [pscustomobject]@{
                SPDataType = $dataType
                SPType     = $type
            }

            $strings = {
                $dataType = [SPSettings]::DataType
                $language = [SPSettings]::CustomLanguage

                Write-Output $([SPLocalization]::LocalisedStrings[$dataType][$language]) }

            $rootObject | Add-Member -MemberType ScriptMethod -Name GetStrings -Value $strings

        # Process each top-level property of the current data type

        if ($dataType -eq "SPAudioDataType")
        {
            $ResolveItemsName = $true
        }

        $resolvedName = $false
            
        if (-Not [SPSettings]::Raw -and $ResolveItemsName)
        {
            if (($properties.Name | Where-Object { $_ -eq "_name" }) -and ($properties.Name | Where-Object { $_ -eq "_items" })) 
            {
                $newName = $($properties['_name'].Value)
                $newValue = $($properties['_items'].Value)
                $resolvedName = $true
            }
        }

        foreach ($property in $properties) 
        {
            if ($resolvedName)
            {
                Add-SPTransformedMember -TargetObject $rootObject -Name $newName -Value $newValue -DataType $dataType -Language $Language
            }
            else 
            {
                Add-SPTransformedMember -TargetObject $rootObject -Name $property.Name -Value $property.Value -DataType $dataType -Language $Language
            }     
        }

        Write-Progress "Done." -Completed

        # Output the final, transformed object for this data type
        $rootObject
        }
    }
}

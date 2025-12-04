<#

PSMacToolkitLib

Copyright (C) 2025 Vincent Anso

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

#>

function Get-LocalizedStrings 
{
    <#
    
    .SYNOPSIS
    Return the localized strings from a specified .loctable file in a given language, e.g. fr, fr_CA, Italian
    or
    Return the localized strings from a specified .strings file

    #>
    
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateScript({ Test-Path $_ })]
        [string]$LiteralPath,
        [string[]]$Localizations = @( (Get-Culture).TwoLetterISOLanguageName ),
        [ValidateScript({ $Localizations -contains $_ })]
        [string]$ExpandLocalization
    )

    $localizedStrings = @{}

    $extension = Get-Item -LiteralPath $LiteralPath | Select-Object -ExpandProperty Extension

    if (@(".strings", ".loctable") -notcontains $extension)
    {
        Write-Error "Unsupported file type ($extension). Expected .strings or .loctable file type."
        return $null
    }

    if ($extension -eq ".strings")
    {
        foreach($localization in $($Localizations | Get-Unique))
        {
            if ($LiteralPath.Contains("en.lproj"))
            {
                $LiteralPath = $LiteralPath -replace "en.lproj", "$localization.lproj"
            }
            elseif ($LiteralPath.Contains("English.lproj"))
            {
                $localizationEnglishName = $([Globalization.CultureInfo]::new($localization).EnglishName)
                
                $LiteralPath = $LiteralPath -replace "English.lproj", "$localizationEnglishName.lproj"
            }
           
            if (-Not (Test-Path -LiteralPath $LiteralPath) )
            {
                $LiteralPath = $LiteralPath -replace "$localization.lproj", "$localizationEnglishName.lproj"

                if (-Not (Test-Path -LiteralPath $LiteralPath) )
                {
                    $LiteralPath = $LiteralPath -replace "English.lproj", "$localizationEnglishName.lproj"
                }
            }

            $check = $(/usr/bin/plutil -lint $LiteralPath)

            if ($check -ne $LiteralPath + ": OK")
            {
                Write-Error $check
                return $null
            }

            $strings = $(/usr/bin/plutil -convert json $LiteralPath -o -) | ConvertFrom-Json -AsHashtable 
            
            $localizedStrings.Add($localization, $strings)
        }
    }
    else
    {
        $check = $(/usr/bin/plutil -lint $LiteralPath)

        if ($check -ne $LiteralPath + ": OK")
        {
            Write-Error $check
            return $null
        }

        $contents = $(/usr/bin/plutil -convert json $LiteralPath -o -) | ConvertFrom-Json -AsHashtable    
        
        ($contents) ? $contents.Remove("LocProvenance") : $(return $null)

        foreach($localization in $($Localizations | Get-Unique))
        {     
            $strings = $contents.$localization

            $localizationEnglishName = $([Globalization.CultureInfo]::new($localization).EnglishName)

            if ([string]::IsNullOrEmpty($strings))
            {
                $strings = $contents.$localizationEnglishName
            }

            if ([string]::IsNullOrEmpty($strings))
            {
                $strings = $contents
            }

            $localizedStrings.Add($localization, $strings)
        }

        if ( [string]::IsNullOrEmpty($strings) )
        {
            Write-Error "Available localizations : $($contents.Keys -join ",")"
        }
    }

    if ($ExpandLocalization)
    {
        if ($extension -eq ".strings")
        {
            ($localizedStrings.$ExpandLocalization) ? $localizedStrings.$ExpandLocalization : $(Write-Error "Localization `"$ExpandLocalization`" cannot be found.")
        }
        else
        {
            ($localizedStrings.$ExpandLocalization) ? $localizedStrings.$ExpandLocalization : $(Write-Error "Localization `"$ExpandLocalization`" cannot be found. Available localizations : $($contents.Keys -join ",")")
        }
    }
    else 
    {
        $localizedStrings
    }
}

class SPSettings
{
    static [string]$Language = "en"
    static [string]$FallbackLanguage = "English"
    static [string]$CustomLanguage = "en"
    static [switch]$Raw = $false
    static [string]$Format = "loctable"
    static [string]$DataType
    static [string[]]$DataTypes
    static [string[]]$AvailableLocalizations
    static [switch]$ResolveItemsName

    static SPSettings()
    {
        [Collections.ArrayList]$dataTypesList = [Collections.ArrayList]::new($(/usr/sbin/system_profiler -listDataTypes))
        $dataTypesList.RemoveAt(0)
        [SPSettings]::DataTypes = $dataTypesList

        $localizations = (Get-ChildItem /System/Library/SystemProfiler/SPOSReporter.spreporter/Contents/Resources/*.lproj | Select-Object -ExpandProperty Name).Split(".") | Where-Object { $_ -ne "lproj" }

        [SPSettings]::AvailableLocalizations = $localizations
    }

    static [string[]] ListDataTypes()
    {
        return [SPSettings]::DataTypes
    }

    static [string[]] ListAvailableLocalizations()
    {
        return [SPSettings]::AvailableLocalizations
    }
}

class SPLocalization
{
    hidden static [hashtable]$LocalisedStrings
    
    static SPLocalization()
    {    
        $spreporters += $(Get-ChildItem /System/Library/SystemProfiler/* | Select-Object -ExpandProperty Name).Split(".") | Where-Object { $_ -ne "spreporter" }

        $spreporters += "/System/Library/PrivateFrameworks/SPSupport.framework"

        $localizedStringsList = [System.Collections.Specialized.ListDictionary]::new()

        $suffix = "Contents/Resources/Localizable.loctable"

        $spsupportsuffix = "Versions/A/Resources/Localizable.loctable"

        if (-Not (Test-Path "/System/Library/PrivateFrameworks/SPSupport.framework/$spsupportsuffix") )
        {
            $spsupportsuffix = "Versions/A/Resources/en.lproj/Localizable.strings"
        
            [SPSettings]::Format = "strings"
        }

        foreach($spreporter in $spreporters)
        {
            if ($spreporter -like "*PrivateFrameworks*")
            {
                $filePath = "$spreporter/$spsupportsuffix"

                $dataType = "SPSupportDataType"
            }
            else 
            {  
                if ([SPSettings]::Format -eq "strings")
                {
                    if (-Not (Test-Path -LiteralPath "/System/Library/SystemProfiler/$spreporter.spreporter/$suffix") )
                    {
                        $suffix = "Contents/Resources/en.lproj/Localizable.strings"
                    
                        if (-Not (Test-Path -LiteralPath "/System/Library/SystemProfiler/$spreporter.spreporter/$suffix") )
                        {
                            $suffix = "Contents/Resources/English.lproj/Localizable.strings"
                        }
                    }
                }

                $filePath = "/System/Library/SystemProfiler/$spreporter.spreporter/$suffix"

                switch ($spreporter) {
                    "SPOSReporter" { 
                        $spreporter = "SPSoftwareReporter"
                    }
                    "SPPlatformReporter" { 
                        $spreporter = "SPHardwareReporter"
                    }
                    "SPCtkReporter" { 
                        $spreporter = "SPSmartCardsReporter"
                    }
                    "SPSyncReporter" { 
                        $spreporter = "SPSyncServicesReporter"
                    }
                    "SPFontReporter" { 
                        $spreporter = "SPFontsReporter"
                    }
                }

                $dataType = $spreporter.Replace("Reporter","DataType")
            }
         
            $strings = Get-LocalizedStrings -LiteralPath $filePath -Localizations $([SPSettings]::ListAvailableLocalizations())

            $localizedStringsList.Add($dataType, $strings)
        }

        [SPLocalization]::LocalisedStrings = $localizedStringsList
    }
    
    static [String]LocalizedString([string]$string, [string]$dataType, [string]$language)
    {          
        if ($string -eq "_name")
        {
            return "Name"
        }

        if ($string -eq "_items")
        {
            return "Items"
        }
        
        if ([string]::IsNullOrEmpty($dataType))
        {
            $dataType = [SPSettings]::DataType
        }

        if ([string]::IsNullOrEmpty($language))
        {
            $language = [SPSettings]::Language
        }
        
        $items = $null

        if ([SPLocalization]::LocalisedStrings[$dataType])
        {
            $items = [SPLocalization]::LocalisedStrings[$dataType][$language]
        }

        foreach ($item in $items)
        {
            if ($item.$string)
            {
                return $item.$string
            }
            else
            {
                foreach($key in $item.GetEnumerator())
                {
                    if ( $string.StartsWith($key.Key + " " ) )
                    {
                        return $string.Replace($($key.Key), $($key.Value))
                    }
                }
            }  
        }

        foreach ($item in [SPLocalization]::LocalisedStrings['SPSupportDataType'][$language])
        {
            if ($item.$string)
            {
                return $item.$string
            }
        }

        return $string
    }
 
    static [hashtable]Dump()
    {
        return [SPLocalization]::LocalisedStrings
    }
}

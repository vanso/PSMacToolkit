<#

PSMacToolkit

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

#Requires -Version 7.2

using module ".\StandardAdditions.psm1"
using module ".\SystemInformation.psm1"
using module ".\LoginWindow.psm1"
using module ".\Network.psm1"

using module ".\PSMacToolkitLib.psm1"


if ( -Not $IsMacOS )
{
    Write-Warning "This module only runs on macOS."
    exit 0
}
else 
{
    if (Test-Path -LiteralPath "$PSScriptRoot/More System Events.zip")
    {
        Write-Verbose "Need to unzip More System Events.app"
        /usr/bin/unzip -qo "$PSScriptRoot/More System Events.zip" -d "$PSScriptRoot/"
        /bin/rm "$PSScriptRoot/More System Events.zip"
        /bin/rm -R $PSScriptRoot/__MACOSX
        /usr/bin/open "$PSScriptRoot/More System Events.app"
    }

    if (Test-Path -LiteralPath "$PSScriptRoot/Notifications Scripting.zip")
    {
        Write-Verbose "Need to unzip Notifications Scripting.app"
        /usr/bin/unzip -qo "$PSScriptRoot/Notifications Scripting.zip" -d "$PSScriptRoot/"
        /bin/rm "$PSScriptRoot/Notifications Scripting.zip"
        /bin/rm -R $PSScriptRoot/__MACOSX
    }

    if (Test-Path -LiteralPath "$PSScriptRoot/Scripting Examples.zip")
    {
        Write-Verbose "Need to unzip Scripting Examples.app"
        /usr/bin/unzip -qo "$PSScriptRoot/Scripting Examples.zip" -d "$PSScriptRoot/"
        /bin/rm "$PSScriptRoot/Scripting Examples.zip"
        /bin/rm -R $PSScriptRoot/__MACOSX
    }
    
    [SPLocalization]::new() | Out-Null
}

if (Get-Module -ListAvailable | Where-Object Name -eq PowerShellOSA)
{
    Import-Module PowerShellOSA
}
else 
{
    Write-Warning "The PowerShellOSA module must be installed to use PSMacToolkit."
    exit 0
}

function Lock-Screen
{
    <#
    
    .SYNOPSIS
    Lock the screen.

    #>
    
    param(
        [switch]$WithScreenSaver
    )

    if ($WithScreenSaver)
    {
        $command = "launch application `"ScreenSaverEngine`""
    }
    else 
    {
        $command = "tell application `"System Events`" to keystroke `"q`" using {control down, command down}"
    }

    /usr/bin/osascript -e $command
}

function Get-UserCredential
{
    <#
    
    .SYNOPSIS
    Prompt the user to enter their credentials.

    #>
    
    param (
        [string]$WithTitle = "PowerShell credential request",
        [string]$WithPrompt = "Enter your credentials.",
        [string]$AsUserName,
        [switch]$UsingKeychainItem,
        [uri]$WithIconFile
    )

    if (-Not $PSBoundParameters['WithTitle'])
    {
        $PSBoundParameters.Add("WithTitle", $WithTitle)
    }

    if (-Not $PSBoundParameters['WithPrompt'])
    {
        $PSBoundParameters.Add("WithPrompt", $WithPrompt)
    }

    $askCredentialsArguments = New-AppleScriptCommand "" $PSBoundParameters

    $script = "tell application `"`"PowerShellOSAUI`"`"
        
        set credentials to ask credentials $askCredentialsArguments

        { UserName:         user name of credentials, ¬
         |Password|:        encrypt secure text (password of credentials), ¬
         |KeychainItem|:    keychain item of credentials, ¬
         |VerifiedPassword|:verified password of credentials } 

    end tell"

    $result = Invoke-OSA $script

    if ($result.OSAScriptErrorNumberKey) { $result ; break }

    [PSCustomObject]@{
        UserName         = $result.UserName
        Password         = $result.Password ? $(ConvertTo-SecureString -String $result.Password) : $null
        KeychainItem     = $result.KeychainItem 
        VerifiedPassword = $result.VerifiedPassword
    }
}

enum DataDetectionType {
    AllTypes
    Link
    PhoneNumber
    Address 
    Date
    TransitInformation 
}

function Invoke-DataDetection
{
    <#
    
    .SYNOPSIS
    Find dates, addresses, links, phone numbers, and transit information in natural language text.

    #>

    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$InputObject,
        [DataDetectionType]$DataType = "AllTypes"
    )

    if ($DataType -ne "AllTypes")
    {
        $Type = "Type$DataType"
    }
    else 
    {
        $Type = "AllSystemTypes"
    }

    $script = "
    use framework `"`"Foundation`"`"
    use scripting additions

    property NSString : a reference to current application's NSString
    property NSDataDetector : a reference to current application's NSDataDetector

    property NSTextCheckingTypeLink : a reference to current application's NSTextCheckingTypeLink
    property NSTextCheckingTypePhoneNumber : a reference to current application's NSTextCheckingTypePhoneNumber
    property NSTextCheckingTypeAddress : a reference to current application's NSTextCheckingTypeAddress
    property NSTextCheckingTypeDate : a reference to current application's NSTextCheckingTypeDate
    property NSTextCheckingTypeTransitInformation : a reference to current application's NSTextCheckingTypeTransitInformation

    property NSTextCheckingAllSystemTypes : a reference to current application's NSTextCheckingAllSystemTypes

    set stringToCheck to `"`"$InputObject`"`"

    set theString to NSString's stringWithString:stringToCheck

    set {theDetector, theError} to NSDataDetector's dataDetectorWithTypes:NSTextChecking$Type |error|:(reference)

    set searchRange to {location:0, |length|:theString's |length|()}

    set matches to theDetector's matchesInString:theString options:0 range:searchRange

    if (count of matches) = 0 then
        return
    end if

    set resultList to {}

    repeat with match in matches
        
        set resultType to match's resultType as integer
        
        set range to match's range as record as list
        
        if resultType = NSTextCheckingTypeLink as integer then
            
            set end of resultList to {DataDetectionType:`"`"Link`"`", |Range|:range, |Result|:match's |URL|'s |absoluteString| as text}
            
        else if resultType = NSTextCheckingTypeDate as integer then
            
            set end of resultList to {DataDetectionType:`"`"Date`"`", |Range|:range, |Result|:match's |date| as date}
            
        else if resultType = NSTextCheckingTypePhoneNumber as integer then
            
            set end of resultList to {DataDetectionType:`"`"PhoneNumber`"`", |Range|:range, |Result|:match's |phoneNumber| as text}
            
        else if resultType = NSTextCheckingTypeAddress as integer then
            
            set end of resultList to {DataDetectionType:`"`"Address`"`", |Range|:range, |Result|:match's addressComponents as record}
            
        else if resultType = NSTextCheckingTypeTransitInformation as integer then
            
            set end of resultList to {DataDetectionType:`"`"TransitInformation`"`", |Range|:range, |Result|:match's components as record}

        end if
        
    end repeat

    return resultList
"
    Invoke-OSA $script
}

function Get-HardwareInfo 
{
    <#
    
    .SYNOPSIS
    Get information about the hardware.

    #>
    
    Invoke-OSA "tell application `"`"More System Events`"`" to get hardware info"
}


Set-Alias -Name Choose-Application                        -Value Select-Application                                        
Set-Alias -Name Choose-Color                              -Value Select-Color                                    
Set-Alias -Name Choose-File                               -Value Select-File                                
Set-Alias -Name Choose-FileName                           -Value Select-FileName
Set-Alias -Name Choose-Folder                             -Value Select-Folder                          
Set-Alias -Name Choose-FromList                           -Value Select-FromList                             
Set-Alias -Name Choose-RemoteApplication                  -Value Select-RemoteApplication                         
Set-Alias -Name Choose-URL                                -Value Select-URL                                                                                                  
Set-Alias -Name Display-Alert                             -Value Show-Alert                                            
Set-Alias -Name Display-Dialog                            -Value Show-Dialog                                      
Set-Alias -Name Display-Notification                      -Value Show-Notification
Set-Alias -Name Log-Out                                   -Value Disconnect-UserSession
Set-Alias -Name Sleep-MacComputer                         -Value Suspend-MacComputer
Set-Alias -Name Connect-EnterpriseWiFiNetwork             -Value Connect-8021XWiFiNetwork
Set-Alias -Name Get-EnterpriseNetworkConfigurationProfile -Value Get-8021XConfigurationProfile
Set-Alias -Name Get-EnterpriseNetworkInfo                 -Value Get-8021XNetworkInfo
Set-Alias -Name Get-EnterpriseNetworkPreferences          -Value Get-8021XPreferences
Set-Alias -Name Start-EnterpriseNetworkClient             -Value Start-8021XClient
Set-Alias -Name Stop-EnterpriseNetworkClient              -Value Stop-8021XClient

 Export-ModuleMember -Alias @(
    'Choose-Application',
    'Choose-Color',
    'Choose-File',
    'Choose-FileName',
    'Choose-Folder',
    'Choose-FromList',
    'Choose-RemoteApplication',
    'Choose-URL',
    'Display-Alert',
    'Display-Dialog',
    'Display-Notification',
    'Log-Out',
    'Sleep-MacComputer',
    'Connect-EnterpriseWiFiNetwork',
    'Get-EnterpriseNetworkConfigurationProfile',
    'Get-EnterpriseNetworkInfo',
    'Get-EnterprisePreferences',
    'Start-EnterpriseNetworkClient',
    'Stop-EnterpriseNetworkClient'
    )

Export-ModuleMember -Function @(
    'Select-Application',
    'Select-Color',
    'Select-File',
    'Select-FileName',
    'Select-Folder',
    'Select-FromList',
    'Select-RemoteApplication',
    'Select-URL',
    'Get-ClipboardInfo',
    'Get-InfoFor',
    'Get-ListDisks',
    'Get-ListFolder',
    'Get-LocalizedString',
    'Get-LocalizedStrings',
    'Get-MacClipboard',
    'Get-PathTo',
    'Get-PathToResource',
    'Get-ScriptingComponents',
    'Get-SPAvailableDataTypes',
    'Get-SPAvailableLocalizations',
    'Get-SPLocalizedString'
    'Get-SystemAttribute',
    'Get-SystemInfo',
    'Get-SystemInformation',
    'Get-UserCredential',
    'Get-VolumeSettings',
    'Invoke-Beep',
    'Invoke-DataDetection',
    'Invoke-Delay',
    'Invoke-Say',
    'Lock-Screen',
    'Disconnect-UserSession',
    'Mount-Volume',
    'Restart-MacComputer',
    'Set-MacClipboard',
    'Set-Volume',
    'Show-Alert',
    'Show-Dialog',
    'Show-Notification',
    'Stop-MacComputer',
    'Suspend-MacComputer',
    'Get-HardwareInfo',
    'Connect-WiFiNetwork',
    'Disconnect-WiFiNetwork',
    'Find-WiFiNetwork',
    'Get-WiFiNetworkInfo',
    'Get-WiFiPreferences',
    'Get-WiFiPreferredNetwork',
    'Get-WiFiState',
    'Set-WiFiState',
    'Connect-8021XWiFiNetwork',
    'Get-8021XConfigurationProfile',
    'Get-8021XNetworkInfo',
    'Get-8021XPreferences',
    'Start-8021XClient',
    'Stop-8021XClient',
    'Get-CurrentNetworkLocation',
    'Get-NetworkEthernetInterface',
    'Get-NetworkInfo',
    'Get-NetworkInterface',
    'Get-NetworkLocation',
    'Get-NetworkService',
    'Get-PrimaryNetworkInterface'
    )

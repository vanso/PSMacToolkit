

function Get-PrimaryNetworkInterface
{
    <#
    
    .SYNOPSIS
    Get information about the primary network interface.

    #>

    Invoke-OSA "tell application `"`"More System Events`"`" to primary network interface"
}

function Get-CurrentNetworkLocation 
{
    <#
    
    .SYNOPSIS
    Get the current location for the current user's network.

    #>

    Invoke-OSA "tell application `"`"System Events`"`" to get properties of current location of network preferences"
}

function Get-NetworkLocation 
{
    <#
    
    .SYNOPSIS
    Get a list of the locations for the current user's network.

    #>

    Invoke-OSA "tell application `"`"System Events`"`" to get properties of every location of network preferences"
}

function Get-NetworkService 
{
    <#
    
    .SYNOPSIS
    Get a list of the services for the current user's network.

    #>

    param(
        [String]$LocationName = $((Get-CurrentNetworkLocation).Name)
    )

    Invoke-OSA "tell application `"`"System Events`"`" to properties of every service of location `"`"$LocationName`"`" of network preferences"
    
}

function  Get-NetworkInterface 
{ 
    <#
    
    .SYNOPSIS
    Get a list of the interfaces for the current user's network.

    #>

    param(
        [String]$LocationName = $((Get-CurrentNetworkLocation).Name),
        [String]$ServiceName
    )

    if ($ServiceName)
    {
        Invoke-OSA "tell application `"`"System Events`"`" to get properties of every interface of service `"`"$ServiceName`"`" of location `"`"$LocationName`"`" of network preferences"
    }
    else 
    {
        Invoke-OSA "tell application `"`"System Events`"`" to get properties of every interface of every service of location `"`"$LocationName`"`" of network preferences"
    }
}

function Get-NetworkEthernetInterface
{
    <#
    
    .SYNOPSIS
    Get a list of the ethernet interfaces for the current user's network.

    #>
    
    Invoke-OSA "tell application `"`"More System Events`"`" to get properties of every ethernet interface of network preferences"
}

function Get-NetworkInfo
{
    <#
    
    .SYNOPSIS
    Get information about the network.

    #>

    [CmdletBinding(DefaultParameterSetName = "Interface")]
    param(
        [Parameter(ParameterSetName="Interface")]
        $ForInterfaceId = $((Get-PrimaryNetworInterface).PrimaryInterfaceId),
        [Parameter(ParameterSetName="Service")]
        $ForServiceId 
    )

    Invoke-OSA (New-AppleScriptCommand "tell application `"`"More System Events`"`" to network info" $PSBoundParameters)

}

function Get-WiFiPreferences
{
    <#
    
    .SYNOPSIS
    Return the preferences for the current WiFi network configuration.

    #>
    
    Invoke-OSA "tell application `"`"More System Events`"`" to get properties of WiFi preferences"
}

function Get-WiFiState
{
    <#
    
    .SYNOPSIS
    Get the Wi-Fi interface power state.

    #>
    
    Invoke-OSA "tell application `"`"More System Events`"`" to get WiFi state"
}

enum WiFiState {
    Enabled
    Disabled 
}

function Set-WiFiState
{
    <#
    
    .SYNOPSIS
    Set the Wi-Fi interface power state.

    #>

    param (
        [ValidateSet("Enabled", "Disabled")]
        [Alias("Value")]
        [WiFiState]$DirectParameter
    )
   
    Invoke-OSA (New-AppleScriptCommand "tell application `"`"More System Events`"`" to set WiFi state to" $PSBoundParameters)
}

function Get-WiFiNetworkInfo
{
    <#
    
    .SYNOPSIS
    Get information about the current Wi-Fi network.

    #>
    
    Invoke-OSA "tell application `"`"More System Events`"`" to get WiFi network info"
}

function Disconnect-WiFiNetwork 
{
    <#
    
    .SYNOPSIS
    Disassociate from any Wi-Fi network.

    #>
    
    Invoke-OSA "tell application `"`"More System Events`"`" to disassociate WiFi network"
}

function Connect-WiFiNetwork
{
    <#
    
    .SYNOPSIS
    Join a Wi-Fi network.

    #>
    
    [CmdletBinding(DefaultParameterSetName = "Keychain")]
    param(
        [Parameter(ParameterSetName="Keychain")]
        [Parameter(ParameterSetName="Password")]
        [Alias("Name")]
        [string]$DirectParameter,
        [Parameter(ParameterSetName="Keychain")]
        [switch]$UsingKeychainItem,
        [Parameter(ParameterSetName="Password")]
        [SecureString]$Password
    )

    Invoke-OSA (New-AppleScriptCommand "tell application `"`"More System Events`"`" to join WiFi network" $PSBoundParameters)
}

function Get-WiFiPreferredNetwork
{
    <#
    
    .SYNOPSIS
    The Wi-Fi networks your computer has connected to.

    #>
    
    Invoke-OSA "tell application `"`"More System Events`"`" to list preferred WiFi networks"
}

function Connect-8021XWiFiNetwork 
{
    <#
    
    .SYNOPSIS
    Join an enterprise Wi-Fi network.

    #>
    
    [CmdletBinding(DefaultParameterSetName = "Certificate")]
    param(
        [Parameter(ParameterSetName="Certificate")]
        [Parameter(ParameterSetName="Keychain")]
        [Parameter(ParameterSetName="Password")]
        [Alias("SSID")]
        [string]$DirectParameter,
        [Parameter(ParameterSetName="Certificate")]
        [Parameter(ParameterSetName="Keychain")]
        [Parameter(ParameterSetName="Password")]
        [String]$WithCertificateName,
        [Parameter(ParameterSetName="Keychain")]
        [switch]$UsingKeychainItem,
        [Parameter(ParameterSetName="Password")]
        [string]$AsUserName,
        [Parameter(ParameterSetName="Password")]
        [securestring]$WithPassword
    )

    Invoke-OSA (New-AppleScriptCommand "tell application `"`"More System Events`"`" to join enterprise WiFi network" $PSBoundParameters)
}

function Get-8021XNetworkInfo 
{
    <#
    
    .SYNOPSIS
    Get information about the eapol client for a given interface.

    #>
    
    param(
        [String]$WithInterfaceId
    )
    
    Invoke-OSA (New-AppleScriptCommand "tell application `"`"More System Events`"`" to get eapol client info" $PSBoundParameters)
}

function Start-8021XClient 
{
    <#
    
    .SYNOPSIS
    Start an eaopl client for a given interface.

    #>
    
    param(
        [String]$WithInterfaceId = "en0",
        [String]$WithProfileId 
    )

    Invoke-OSA (New-AppleScriptCommand "tell application `"`"More System Events`"`" to start eapol client" $PSBoundParameters)
}

function Stop-8021XClient 
{
    <#
    
    .SYNOPSIS
    Stop an eaopl client for a given interface.

    #>
    
    param(
        [String]$WithInterfaceId
    )
    
    Invoke-OSA (New-AppleScriptCommand "tell application `"`"More System Events`"`" to stop eapol client" $PSBoundParameters)
}

function Get-8021XPreferences 
{
    <#
    
    .SYNOPSIS
    Get the 802.1X preferences for the current user's network.

    #>
    
    Invoke-OSA "tell application `"`"More System Events`"`" to get properties of IEEE8021X network preferences"
}

function Get-8021XConfigurationProfile 
{
    <#
    
    .SYNOPSIS
    Get 802.1X settings from the configuration profiles for the current user's network service.

    #>
    
    Invoke-OSA "tell application `"`"More System Events`"`" to get properties of every configuration profile of IEEE8021X network preferences"
}

function Find-WiFiNetwork 
{
    <#
    
    .SYNOPSIS
    Scans for WiFi networks.

    #>

    param (
        [String]$WithName
    )

    Invoke-OSA (New-AppleScriptCommand "tell application `"`"More System Events`"`" to scan WiFi networks" $PSBoundParameters)   
}

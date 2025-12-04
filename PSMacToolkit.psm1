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

using module ".\PSMacToolkitLib.psm1"

if ( -Not $IsMacOS )
{
    Write-Warning "This module only runs on macOS."
    exit 0
}
else 
{
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

function Get-SystemInfo 
{
    <#
    
    .SYNOPSIS
    Get information about the system.

    #>
    
    Invoke-OSA "system info"
}

function Get-InfoFor 
{
    <#
    
    .SYNOPSIS
    Return information for a file or folder.

    #>

    param (
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0, Mandatory = $true)]
        [ValidateScript({ Test-Path -LiteralPath $_ })]
        [Alias("Path")]
        [uri]$DirectParameter,
        [switch]$Size
    )

    Invoke-OSA (New-AppleScriptCommand "info for" $PSBoundParameters) 
}

function Get-ListDisks
{
    <#
    
    .SYNOPSIS
    Return a list of the currently mounted volumes.

    #>
    
    Invoke-OSA "list disks"
}

function Get-ListFolder 
{
    <#
    
    .SYNOPSIS
        Return the contents of a specified folder.

    #>
    
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
        [Alias("Path")]
        [Uri]$DirectParameter,
        [switch]$Invisibles
    )

    Invoke-OSA (New-AppleScriptCommand "list folder" $PSBoundParameters)
}

function Get-ClipboardInfo 
{
    <#
    
    .SYNOPSIS
    Return information about the clipboard.

    #>
    
    param (
       [string]$For
    )

    Invoke-OSA (New-AppleScriptCommand "clipboard info" $PSBoundParameters)
}

function Get-MacClipboard 
{
    <#
    
    .SYNOPSIS
    Return the contents of an application’s clipboard.

    #>
    
    param (
       [string]$ForApplication
    )

    if ($PSBoundParameters.ContainsKey("ForApplication"))
    {
        /usr/bin/osascript -e "tell application `"$ForApplication`" to activate"
    }

    Invoke-OSA (New-AppleScriptCommand "the clipboard" $PSBoundParameters @("ForApplication"))
}

function Set-MacClipboard 
{
    <#
    
    .SYNOPSIS
    Place data on an application’s clipboard.

    #>

    param (
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias("Value")]
        $DirectParameter,
        [string]$ForApplication
    )

    if ($PSBoundParameters.ContainsKey("ForApplication"))
    {
        /usr/bin/osascript -e "tell application `"$ForApplication`" to activate"
    }
    
    Invoke-OSA (New-AppleScriptCommand "set the clipboard to" $PSBoundParameters @("ForApplication"))
    
}

function Get-VolumeSettings
{
    <#
    
    .SYNOPSIS
    Get the sound output and input volume settings.

    #>
    
    Invoke-OSA "get volume settings"
}

function Set-Volume
{
    <#
    
    .SYNOPSIS
    Set the sound output and/or input volume.

    #>
    
    [CmdletBinding(DefaultParameterSetName = "VolumeDeprecated")]
    param(
        [Parameter(ParameterSetName = 'VolumeDeprecated')]
        [ValidateRange(0, 7)]
        [Parameter(Position = 0)]
        [Byte]$DirectParameter,
        [Parameter(ParameterSetName = 'Volume')]
        [ValidateRange(0, 100)]
        [Byte]$OutputVolume,
        [Parameter(ParameterSetName = 'Volume')]
        [ValidateRange(0, 100)]
        [Byte]$InputVolume,
        [Parameter(ParameterSetName = 'Volume')]
        [ValidateRange(0, 100)]
        [Byte]$AlertVolume,
        [Parameter(ParameterSetName = 'Volume')]
        [Boolean]$OutputMuted
    )

    Invoke-OSA (New-AppleScriptCommand "set volume" $PSBoundParameters)
}

function Get-SystemAttribute 
{
    <#
    
    .SYNOPSIS
    Test attributes of this computer.

    #>
    
    param (
        [string]$DirectParameter,
        [int]$Has
    )
    
    Invoke-OSA (New-AppleScriptCommand "system attribute" $PSBoundParameters)
}


function Select-Color 
{
    <#
    
    .SYNOPSIS
    Choose a color.

    #>
    
    param (
        [array]$DefaultColor
    )
    
    Invoke-OSA (New-AppleScriptCommand "choose color" $PSBoundParameters)
}

enum EAlT {
    Critical
    Informational
    Warning
}

function Show-Alert
{
    <#
    
    .SYNOPSIS
    Display an alert.

    #>
    
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [Alias("Text")]
        [string]$DirectParameter,
        [string]$Message,
        [EAlT]$As = "Informational",
        [Array]$Buttons,
        [string]$DefaultButton,
        [string]$CancelButton,
        [int]$GivingUpAfter
    )

    Invoke-OSA (New-AppleScriptCommand "display alert" $PSBoundParameters)
}

enum Stic {
    Stop
    Note
    Caution
}

function Show-Dialog
{
    <#
    
    .SYNOPSIS
    Display a dialog box, optionally requesting user input.

    #>
    
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [Alias("Text")]
        [string]$DirectParameter,
        [string]$DefaultAnswer,
        [switch]$HiddenAnswer,
        [string[]]$Buttons,
        [string]$DefaultButton,
        [string]$CancelButton,
        [string]$WithTitle,
        [Stic]$WithIcon,
        [int]$GivingUpAfter,
        [switch]$AsSecureString
    )

    $result = Invoke-OSA (New-AppleScriptCommand "display dialog" $PSBoundParameters -IgnoreParameters @("AsSecureString"))

    if ($HiddenAnswer -and $AsSecureString)
    {
        if ($result.TextReturned)
        {
            $encryptedString = ConvertTo-SecureString $($result.TextReturned) -AsPlainText
            
            $result.TextReturned = $encryptedString
        }
    }

    $result
}

function Select-FromList 
{
    <#
    
    .SYNOPSIS
    Choose one or more items from a list.

    #>
    
    param (
        [Parameter(Position = 0, Mandatory = $true)]    
        [Alias("List")]
        [array]$DirectParameter,
        [string]$WithTitle,
        [string]$WithPrompt,
        [array]$DefaultItems,
        [string]$OkButtonName,
        [string]$CancelButtonName,
        [switch]$MultipleSelectionsAllowed,
        [switch]$EmptySelectionAllowed

    )
    
    Invoke-OSA (New-AppleScriptCommand "choose from list" $PSBoundParameters)
}


function Show-Notification
{
    <#
    
    .SYNOPSIS
    Display a notification. At least one of the body text and the title must be specified.

    #>
    
    param (
        [Parameter(Position = 0, Mandatory = $true)]    
        [Alias("Text")]
        [string]$DirectParameter,
        [string]$WithTitle,
        [string]$Subtitle,
        [string]$SoundName
    )
    
    Invoke-OSA (New-AppleScriptCommand "display notification" $PSBoundParameters)
}

function Delay 
{
    <#
    
    .SYNOPSIS
    Pause for a fixed amount of time.

    #>
    
    param (
        [Alias("Seconds")]
        [int]$DirectParameter
    )

    Invoke-OSA (New-AppleScriptCommand "delay" $PSBoundParameters)
}

function Invoke-Beep
{
    <#
    
    .SYNOPSIS
    Beep 1 or more times.

    #>
    
    param (
        [Alias("Number")]
        [int]$DirectParameter
    )

    Invoke-OSA (New-AppleScriptCommand "beep" $PSBoundParameters)
}

function Select-RemoteApplication 
{
    <#
    
    .SYNOPSIS
    Choose a running application on a remote machine or on this machine.

    #>
    
    param (
        [string]$WithTitle,
        [string]$WithPrompt
    )

    Invoke-OSA (New-AppleScriptCommand "choose remote application" $PSBoundParameters)
}

enum ChooseApplicationType {
   Application
   Alias
}

function Select-Application 
{
    <#
    
    .SYNOPSIS
    Choose an application on this machine or the network.

    #>
    
    param (
        [string]$WithTitle,
        [string]$WithPrompt,
        [switch]$MultipleSelectionsAllowed,
        [ChooseApplicationType]$As
    )
    
    Invoke-OSA (New-AppleScriptCommand "choose application" $PSBoundParameters)
}


function Select-File
{
    <#
    
    .SYNOPSIS
    Choose a file on a disk or server.

    #>
    
    param (
        [string]$WithPrompt,
        [array]$OfType,
        [ValidateScript({ Test-Path -LiteralPath $_ })]
        [Uri]$DefaultLocation,
        [switch]$Invisibles,
        [switch]$MultipleSelectionsAllowed,
        [switch]$ShowingPackageContents
    )
    
    Invoke-OSA (New-AppleScriptCommand "choose file" $PSBoundParameters)
}

function Select-Folder
{
    <#
    
    .SYNOPSIS
    Choose a folder on a disk or server.

    #>
    
    param (
        [string]$WithPrompt,
        [Uri]$DefaultLocation,
        [switch]$Invisibles,
        [switch]$MultipleSelectionsAllowed,
        [switch]$ShowingPackageContents
    )
    
    Invoke-OSA (New-AppleScriptCommand "choose folder" $PSBoundParameters)
}

enum ServerType {
    WebServers
    FTPServers
    TelnetHosts
    FileServers
    NewsServers
    DirectoryServices
    MediaServers
    RemoteApplications
}

function Select-URL 
{
    <#
    
    .SYNOPSIS
    Choose a service on the Internet.

    #>
    
    param (
        [ServerType]$Showing,
        [switch]$EditableUrl
    )
    
    Invoke-OSA (New-AppleScriptCommand "choose URL" $PSBoundParameters)
}

function Select-FileName 
{
    <#
    
    .SYNOPSIS
    Get a new file reference from the user, without creating the file.

    #>
    
    param (
        [string]$WithPrompt,
        [string]$DefaultName,
        [ValidateScript({ Test-Path -LiteralPath $_ })]
        [Uri]$DefaultLocation
    )

    Invoke-OSA (New-AppleScriptCommand "choose file name" $PSBoundParameters)
}

function Invoke-Say 
{
    <#
    
    .SYNOPSIS
    Speak the given text.

    #>
    
    param (
        [Parameter(Position = 0, Mandatory = $true)]    
        [Alias("Text")]
        [string]$DirectParameter,
        [string]$Displaying,
        [string]$Using,
        [int]$SpeakingRate,
        [ValidateRange(0, 127)]
        [byte]$Pitch,
        [ValidateRange(0, 127)]
        [byte]$Modulation,
        [ValidateRange(0, 1)]
        [double]$Volume,
        [switch]$StoppingCurrentSpeech,
        [switch]$WaitingUntilCompletion,
        [Uri]$SavingTo
    )

    Invoke-OSA (New-AppleScriptCommand "say" $PSBoundParameters)
}

function Mount-Volume 
{
    <#
    
    .SYNOPSIS
    Mount the specified server volume.

    #>
    
    param (
        [Parameter(Position = 0, Mandatory = $true)]    
        [Alias("Path")]
        [string]$DirectParameter,
        [string]$OnServer,
        [string]$InAppletalkZone,
        [string]$AsUserName,
        [securestring]$WithPassword
    )
    
    Invoke-OSA (New-AppleScriptCommand "mount volume" $PSBoundParameters)
}

enum FolderName {
    CurrentApplication
    FrontmostApplication
    Me
    It
    ApplicationSupport
    ApplicationsFolder
    Desktop
    DesktopPicturesFolder
    DocumentsFolder
    DownloadsFolder
    FavoritesFolder
    FolderActionScripts
    Fonts
    Help
    HomeFolder
    InternetPlugins
    KeychainFolder
    LibraryFolder
    ModemScripts
    MoviesFolder
    MusicFolder
    PicturesFolder
    Preferences
    PrinterDescriptions
    PublicFolder
    ScriptingAdditionsFolder
    ScriptsFolder
    ServicesFolder
    SharedDocuments
    SharedLibraries
    SitesFolder
    StartupDisk
    StartupItems
    SystemFolder
    SystemPreferences
    TemporaryItems
    Trash
    UsersFolder
    UtilitiesFolder
    WorkflowsFolder
    Voices
    AppleMenu
    ControlPanels
    ControlStripModules
    Extensions
    LauncherItemsFolder
    PrinterDrivers
    PrintMonitor
    ShutdownFolder
    SpeakableItems
    Stationery
}

enum DomainType {
    SystemDomain
    LocalDomain
    NetworkDomain
    UserDomain
    ClassicDomain
}

function Get-PathTo
{
    <#
    
    .SYNOPSIS
    Return the full path to the specified application, script or folder.

    #>
    
    [CmdletBinding(DefaultParameterSetName = "PathTo")]
    param (
        [Parameter(ParameterSetName = 'PathToApplication')]  
        [String]$Application,
        [Parameter(ParameterSetName = 'PathTo')]
        [Parameter(Position = 0, Mandatory = $false)]    
        [Alias("Folder")]
        [FolderName]$DirectParameter,
        [Parameter(ParameterSetName = 'PathTo')]
        [DomainType]$From,
        [Parameter(ParameterSetName = 'PathTo')]
        [switch]$FolderCreation
    )

    Invoke-OSA (New-AppleScriptCommand "path to" $PSBoundParameters)
}

function Get-PathToResource 
{
    <#
    
    .SYNOPSIS
    Return the full path to the specified resource.

    #>
    
    param (
        [Parameter(Position = 0, Mandatory = $true)]    
        [Alias("Text")]
        [string]$DirectParameter,
        [Uri]$InBundle,
        [string]$InDirectory
    )

    Invoke-OSA (New-AppleScriptCommand "path to resource" $PSBoundParameters)
}

function Get-LocalizedString 
{
    <#
    
    .SYNOPSIS
    Return the localized string for the specified key.

    #>
    
    [CmdletBinding()]
    param (
        [Alias("Text")]    
        [string]$DirectParameter,
        [string]$FromTable,
        [Uri]$InBundle
    )

    Invoke-OSA (New-AppleScriptCommand "localized string" $PSBoundParameters)
}

function Get-ScriptingComponents
{
    <#
    
    .SYNOPSIS
    Return a list of all scripting components (e.g. AppleScript).

    #>
    
    Invoke-OSA "scripting components"
}


function Disconnect-UserSession
{
    <#
    
    .SYNOPSIS
    Log out the current user.

    #>
    
    param(
        [switch]$Force
    )

    $kCoreEventClass = 'aevt'

    $kAELogOut = 'logo'
    $kAEReallyLogOut = 'rlgo'

    $eventId = $Force ? $kAEReallyLogOut : $kAELogOut

    /usr/bin/osascript -e "tell application `"loginwindow`" to «event $kCoreEventClass$eventId»"
}

function Restart-MacComputer
{
    <#
    
    .SYNOPSIS
    Restart the computer.

    #>
    
    param(
        [switch]$Force
    )
    
    $kCoreEventClass = 'aevt'

    $kAEShowRestartDialog = 'rrst'
    $kAERestart = 'rest'

    $eventId = $Force ? $kAERestart : $kAEShowRestartDialog

    /usr/bin/osascript -e "tell application `"loginwindow`" to «event $kCoreEventClass$eventId»"
}


function Stop-MacComputer
{
    <#
    
    .SYNOPSIS
    Shut Down the computer.

    #>

    param(
        [switch]$Force
    )

    $kCoreEventClass = 'aevt'

    $kAEShowShutdownDialog = 'rsdn'
    $kAEShutDown = 'shut'

    $eventId = $Force ? $kAEShutDown : $kAEShowShutdownDialog

    /usr/bin/osascript -e "tell application `"loginwindow`" to «event $kCoreEventClass$eventId»"
}


function Suspend-MacComputer
{
    <#
    
    .SYNOPSIS
    Put the computer to sleep.

    #>
    
    $kCoreEventClass = 'aevt'
    $kAESleep = 'slep'

    $eventId = $kAESleep

    /usr/bin/osascript -e "tell application `"loginwindow`" to «event $kCoreEventClass$eventId»"
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

Set-Alias -Name Choose-Application       -Value Select-Application                                        
Set-Alias -Name Choose-Color             -Value Select-Color                                    
Set-Alias -Name Choose-File              -Value Select-File                                
Set-Alias -Name Choose-FileName          -Value Select-FileName
Set-Alias -Name Choose-Folder            -Value Select-Folder                          
Set-Alias -Name Choose-FromList          -Value Select-FromList                             
Set-Alias -Name Choose-RemoteApplication -Value Select-RemoteApplication                         
Set-Alias -Name Choose-URL               -Value Select-URL                                                                                                  
Set-Alias -Name Display-Alert            -Value Show-Alert                                            
Set-Alias -Name Display-Dialog           -Value Show-Dialog                                      
Set-Alias -Name Display-Notification     -Value Show-Notification
Set-Alias -Name Log-Out                  -Value Disconnect-UserSession
Set-Alias -Name Sleep-MacComputer        -Value Suspend-MacComputer

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
    'Sleep-MacComputer'
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
    'Suspend-MacComputer'
    )

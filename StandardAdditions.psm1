
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
        [string]$WithTitle = "PowerShell",
        [string]$Subtitle,
        [string]$SoundName
    )
    
    if (-Not $PSBoundParameters['WithTitle'])
    {
        $PSBoundParameters.Add("WithTitle", $WithTitle)
    }

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

Show-Notification "message" -ContentImage "/Applications/PowerShell.app/Contents/Resources/Powershell.icns"
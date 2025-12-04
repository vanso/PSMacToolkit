# PSMacToolkit

**PSMacToolkit** is a PowerShell module.

Ideal for macOS administrators and users. It provides a broad set of functions to simplify system management and enhance user interaction. The module enables actions such as retrieving system information, selecting files and folders, displaying dialogs and notifications, and interacting with applications. By combining native macOS capabilities with PowerShell, it helps streamline everyday tasks and improve workflow efficiency.

## Requirements

- PowerShell 7.2 or later
- [PowerShellOSA](https://github.com/vanso/PowerShellOSA) module (this will be installed automatically if not present)

## Supported Platforms

- macOS 10.15 or later (Intel and Apple Silicon)

## Installation

```powershell
PS> Install-Module -Name PSMacToolkit
```

## Usage

```powershell
Get-SystemInfo

Show-Dialog "What is your name?" -Buttons @("Cancel", "OK") -DefaultButton "OK" -CancelButton "Cancel" -GivingUpAfter 15 -DefaultAnswer (Get-SystemInfo).LongUserName

$theAlertText = "An error has occurred."
$theAlertMessage = "The amount of available free space is dangerously low. Would you like to continue?"
Show-Alert $theAlertText -Message $theAlertMessage -As Critical -Buttons @("Don't Continue", "Continue") -DefaultButton "Continue" -CancelButton "Don't Continue"

Select-File -OfType @("public.jpeg", "public.png") -DefaultLocation (Get-PathTo PicturesFolder)

Get-SystemAttribute 'sysa'

Lock-Screen -WithScreenSaver

Restart-MacComputer -Force

Get-SystemInformation -Fast

Get-SystemInformation SPSoftwareDataType, SPHardwareDataType -Language "ja"

Get-SystemInformation SPSoftwareDataType -Raw

Show-Dialog "Enter password:" -DefaultAnswer "" -HiddenAnswer -AsSecureString

Select-FromList @("Sal", "Sue", "Yoshi", "Wayne", "Carla") -WithPrompt "Pick your favorite club members:" -DefaultItems @("Sue", "Carla") -MultipleSelectionsAllowed

Get-InfoFor "/System/Applications/TextEdit.app"

Invoke-DataDetection "Contact jsnover@contoso.com, call +1-555-123-4567, visit 1 Infinite Loop, Cupertino, CA, or meet me on 2025-10-31. https://www.powershellgallery.com. Let's fly with AF84 to San Francisco!"
```

## Available Functions in the Module

| Function | Description |
|----------|-------------|
| **🔊 Audio & Sound Control**  ||
| Get-VolumeSettings | Get the sound output and input volume settings. |
| Set-Volume | Set the sound output and/or input volume. |
| Invoke-Beep | Beep 1 or more times. |
| Invoke-Say | Speak the given text. |
| **⚙️ Automation & Scripting** ||
| Get-ScriptingComponents | Return a list of all scripting components (e.g., AppleScript). |
| Invoke-DataDetection | Find dates, addresses, links, phone numbers, and transit information in natural language text. |
| Invoke-Delay | Pause for a fixed amount of time. |
| **📋 Clipboard**  ||
| Get-ClipboardInfo | Return information about the clipboard. |
| Get-MacClipboard | Return the contents of an application’s clipboard. |
| Set-MacClipboard | Place data on an application’s clipboard. |
| **📁 Files, Folders & Resources**  ||
| Get-InfoFor | Return information for a file or folder. |
| Get-ListFolder | Return the contents of a specified folder. |
| Get-ListDisks | Return a list of the currently mounted volumes. |
| Get-PathTo | Return the full path to the specified application, script, or folder. |
| Get-PathToResource | Return the full path to the specified resource. |
| Mount-Volume | Mount the specified server volume. |
| **🌍 Localization** ||
| Get-LocalizedString | Return the localized string for the specified key. |
| Get-LocalizedStrings | Return the localized strings from a .loctable file in a given language, or from a .strings file. |
| **🎨 User Interface & Interaction**  ||
| Get-UserCredential | Prompt the user to enter their credentials. |
| Select-File | Choose a file on a disk or server. |
| Select-FileName | Get a new file reference from the user, without creating the file. |
| Select-Folder | Choose a folder on a disk or server. |
| Select-Application | Choose an application on this machine or the network. |
| Select-RemoteApplication | Choose a running application on a remote machine or on this machine. |
| Select-Color | Choose a color. |
| Select-FromList | Choose one or more items from a list. |
| Select-URL | Choose a service on the Internet. |
| Show-Alert | Display an alert. |
| Show-Dialog | Display a dialog box, optionally requesting user input. |
| Show-Notification | Display a notification. At least one of the body text and the title must be specified. |
| **🖥️ System & Hardware**  ||
| Get-SystemInfo | Get information about the system. |
| Get-SystemInformation | Reports system hardware and software configuration. |
| Get-SystemAttribute | Test attributes of this computer. |
| Get-SPAvailableDataTypes | Lists the available datatypes for Get-SystemInformation. |
| Get-SPAvailableLocalizations | Lists the available localizations for Get-SystemInformation. |
| Get-SPLocalizedString | Gets a localized string for system_profiler. |
| Restart-MacComputer | Restart the computer. |
| Stop-MacComputer | Shut down the computer. |
| Suspend-MacComputer | Put the computer to sleep. |
| **👤 User Session & Accounts**  ||
| Disconnect-UserSession | Log out the current user. |
| Lock-Screen | Lock the screen. |

## Available Aliases in the Module

| Alias name (AppleScript naming)      |          Function name                                                    |
|:-------------------------|:-------------------------------------------------------------------------------------|
| Choose-Application       | Select-Application            |
| Choose-Color             | Select-Color                  |
| Choose-File              | Select-File                   |
| Choose-FileName          | Select-FileName               |
| Choose-Folder            | Select-Folder                 |
| Choose-FromList          | Select-FromList               |
| Choose-RemoteApplication | Select-RemoteApplication      |
| Choose-URL               | Select-URL                    |
| Display-Alert            | Show-Alert                    |
| Display-Dialog           | Show-Dialog                   |
| Display-Notification     | Show-Notification             |
| Log-Out                  | Disconnect-UserSession        |
| Sleep-MacComputer        | Suspend-MacComputer           |

## License

This module is released under the terms of the GNU General Public License (GPL), Version 2.

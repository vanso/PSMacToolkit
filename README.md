# PSMacToolkit

**PSMacToolkit** is a PowerShell module.

This PowerShell module, ideal for macOS administrators and users, enhances user interactions and system management with a broad set of functions. These capabilities include common tasks, among others, such as file and folder selection, system information retrieval, clipboard operations, and user notifications. It also provides practical tools for managing Wi-Fi connections, 802.1X network profiles, and basic system actions like volume control, screen locking, and power management.

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
| **📡 Network & Connectivity** | |
| Get-CurrentNetworkLocation | Get the current location for the current user's network. |
| Get-NetworkEthernetInterface | Get a list of the ethernet interfaces for the current user's network. |
| Get-NetworkInfo | Get information about the network. |
| Get-NetworkInterface | Get a list of the interfaces for the current user's network. |
| Get-NetworkLocation | Get a list of the locations for the current user's network. |
| Get-NetworkService | Get a list of the services for the current user's network. |
| Get-PrimaryNetworkInterface | Get information about the primary network interface. |
| **Wi-Fi** | |
| Connect-WiFiNetwork | Join a Wi-Fi network. |
| Disconnect-WiFiNetwork | Disassociate from any Wi-Fi network. |
| Find-WiFiNetwork | Scans for WiFi networks. |
| Get-WiFiNetworkInfo | Get information about the current Wi-Fi network. |
| Get-WiFiPreferences | Return the preferences for the current WiFi network configuration. |
| Get-WiFiPreferredNetwork | The Wi-Fi networks your computer has connected to. |
| Get-WiFiState | Get the Wi-Fi interface power state. |
| Set-WiFiState | Set the Wi-Fi interface power state. |
| **802.1X** | |
| Connect-8021XWiFiNetwork | Join an enterprise Wi-Fi network. |
| Get-8021XConfigurationProfile | Get 802.1X settings from the configuration profiles for the current user's network service. |
| Get-8021XPreferences | Get the 802.1X preferences for the current user's network. |
| Get-8021XNetworkInfo | Get information about the eapol client for a given interface |
| Start-8021XClient | Start an eaopl client for a given interface. |
| Stop-8021XClient | Stop an eaopl client for a given interface. |
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
| Get-HardwareInfo | Get information about the hardware. |
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

| Alias name     |          Function name                                                    |
|:-------------------------|:-------------------------------------------------------------------------------------|
| Choose-Application       | Select-Application            |
| Choose-Color             | Select-Color                  |
| Choose-File              | Select-File                   |
| Choose-FileName          | Select-FileName               |
| Choose-Folder            | Select-Folder                 |
| Choose-FromList          | Select-FromList               |
| Choose-RemoteApplication | Select-RemoteApplication      |
| Choose-URL               | Select-URL                    |
| Connect-EnterpriseWiFiNetwork | Connect-8021XWiFiNetwork |
| Display-Alert            | Show-Alert                    |
| Display-Dialog           | Show-Dialog                   |
| Display-Notification     | Show-Notification             |
| Get-EnterpriseNetworkConfigurationProfile | Get-8021XConfigurationProfile |
| Get-EnterpriseNetworkInfo | Get-8021XNetworkInfo | 
| Get-EnterprisePreferences | Get-8021XPreferences | 
| Log-Out                  | Disconnect-UserSession        |
| Sleep-MacComputer        | Suspend-MacComputer           |
| Start-EnterpriseNetworkClient | Start-8021XClient |
| Stop-EnterpriseNetworkClient | Stop-8021XClient |

## License

This module is released under the terms of the GNU General Public License (GPL), Version 2.

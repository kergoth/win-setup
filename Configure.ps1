# Get the ID and security principal of the current user account
$myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal = new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
 
# Get the security principal for the Administrator role
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator
 
# Check to see if we are currently running "as Administrator"
if (-Not $myWindowsPrincipal.IsInRole($adminRole)) {
    # We are not running "as Administrator" - so relaunch as administrator
 
    # Create a new process object that starts PowerShell
    $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
 
    # Specify the current script path and name as a parameter
    $newProcess.Arguments = $myInvocation.MyCommand.Definition;
 
    # Indicate that the process should be elevated
    $newProcess.Verb = "runas";
 
    # Start the new process
    [System.Diagnostics.Process]::Start($newProcess);
 
    # Exit from the current, unelevated, process
    exit
}


# Now elevated to Administrator
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

. $PSScriptRoot\Components\Common.ps1

Write-Verbose "Downloading Sophia Script"
$sophiadir = $env:TEMP + '/sophia'
try {
    $sophia = Get-FileFromUrl https://github.com/farag2/Sophia-Script-for-Windows/releases/download/5.12.1/Sophia.Script.v5.12.1.zip
    try {
        Expand-Archive $sophia -DestinationPath $sophiadir -Force
    }
    finally {
        Remove-Item $sophiadir -Recurse -Force
    }
}
finally {
    Remove-Item $sophia
}

$sophiaScript = "$env:TEMP\sophia\Sophia Script v5.12.1"
Remove-Module -Name Sophia -Force -ErrorAction Ignore
Import-Module -Name $sophiaScript\Manifest\Sophia.psd1 -PassThru -Force
Import-LocalizedData -BindingVariable Global:Localization -FileName Sophia -BaseDirectory $sophiaScript\Localizations

try {
    Checkings
}
catch {
}

CreateRestorePoint

# Small icons in taskbar
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarSmallIcons" -Type DWord -Value 1

# Enable Clipboard History
New-ItemProperty -Path HKCU:\Software\Microsoft\Clipboard -Name EnableClipboardHistory -PropertyType DWord -Value 0 -Force

# Associate *.txt to Notepad++
if (Test-Path "$env:ProgramFiles\Notepad++\notepad++.exe") {
    Set-Association -ProgramPath "%ProgramFiles%\Notepad++\notepad++.exe" -Extension .txt -Icon "%ProgramFiles%\Notepad++\notepad++.exe,0"
}

# Uninstall OneDrive
OneDrive -Uninstall
if (-Not (Get-ChildItem $env:USERPROFILE\OneDrive -ErrorAction Ignore)) {
    Remove-Item -Recurse -Force $env:USERPROFILE\OneDrive
}

# Disable Scheduled Tasks
[string[]]$CheckedScheduledTasks = @(
    # Collects program telemetry information if opted-in to the Microsoft Customer Experience Improvement Program
    "ProgramDataUpdater",

    # This task collects and uploads autochk SQM data if opted-in to the Microsoft Customer Experience Improvement Program
    "Proxy",

    # If the user has consented to participate in the Windows Customer Experience Improvement Program, this job collects and sends usage data to Microsoft
    "Consolidator",

    # The USB CEIP (Customer Experience Improvement Program) task collects Universal Serial Bus related statistics and information about your machine and sends it to the Windows Device Connectivity engineering group at Microsoft
    "UsbCeip",

    # The Windows Disk Diagnostic reports general disk and system information to Microsoft for users participating in the Customer Experience Program
    "Microsoft-Windows-DiskDiagnosticDataCollector"
)

$Tasks = Get-ScheduledTask | Where-Object -FilterScript { ($_.State -eq "Ready") -and ($_.TaskName -in $CheckedScheduledTasks) }
$Tasks | Disable-ScheduledTask

DiagTrackService -Disable
DiagnosticDataLevel -Minimal
ErrorReporting -Disable
FeedbackFrequency -Never
SigninInfo -Disable
LanguageListAccess -Disable
AdvertisingID -Disable
WindowsWelcomeExperience -Hide
WindowsTips -Enable
SettingsSuggestedContent -Hide
AppsSilentInstalling -Disable
WhatsNewInWindows -Disable
TailoredExperiences -Disable
BingSearch -Disable
CheckBoxes -Disable
HiddenItems -Enable
FileExtensions -Show
MergeConflicts -Show
OpenFileExplorerTo -ThisPC
CortanaButton -Hide
OneDriveFileExplorerAd -Hide
FileTransferDialog -Detailed
3DObjects -Hide
QuickAccessRecentFiles -Hide
QuickAccessFrequentFolders -Hide
TaskViewButton -Hide
PeopleTaskbar -Hide
WindowsInkWorkspace -Hide
MeetNow -Hide
NewsInterests -Disable
UnpinTaskbarShortcuts -Shortcuts Edge, Store, Mail
ControlPanelView -LargeIcons
JPEGWallpapersQuality -Max
TaskManagerWindow -Expanded
RestartNotification -Show
ShortcutsSuffix -Disable
PrtScnSnippingTool -Enable
StorageSense -Enable
StorageSenseTempFiles -Enable
StorageSenseFrequency -Month
MappedDrivesAppElevatedAccess -Enable
DeliveryOptimization -Disable
UpdateMicrosoftProducts -Enable
NetworkAdaptersSavePower -Disable
ReservedStorage -Disable
StickyShift -Disable
Autoplay -Disable
SaveRestartableApps -Enable
NetworkDiscovery -Enable
RecentlyAddedApps -Hide
AppSuggestions -Hide
HEIF -Install
CortanaAutostart -Disable
XboxGameBar -Disable
XboxGameTips -Disable
NetworkProtection -Enable
PUAppsDetection -Enable
DefenderSandbox -Enable
DismissMSAccount
DismissSmartScreenFilter
WindowsScriptHost -Disable
WindowsSandbox -Enable
MSIExtractContext -Show
CABInstallContext -Show
MultipleInvokeContext -Enable
Write-Output "Remember to reboot!"
Errors

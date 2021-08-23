function Invoke-Sophia ($sophiascript) {
    Remove-Module -Name Sophia -Force -ErrorAction Ignore
    Import-Module -Name $sophiaScript\Manifest\Sophia.psd1 -Force
    Import-LocalizedData -BindingVariable Global:Localization -FileName Sophia -BaseDirectory $sophiaScript\Localizations

    try {
        Checkings
    }
    catch {
    }

    CreateRestorePoint

    # Enable app sideloading
    New-ItemProperty -Path HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock -Name AllowAllTrustedApps -Type DWord -Value 1 -Force

    # Enable windows developer mode
    New-ItemProperty -Path HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock -Name AllowDevelopmentWithoutDevLicense -Type DWord -Value 1 -Force

    # Small icons in taskbar
    Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name "TaskbarSmallIcons" -Type DWord -Value 1

    # Enable Clipboard History
    New-ItemProperty -Path HKCU:\Software\Microsoft\Clipboard -Name EnableClipboardHistory -PropertyType DWord -Value 0 -Force

    # Associate *.txt to Notepad++
    if (Test-Path "$env:ProgramFiles\Notepad++\notepad++.exe") {
        Set-Association -ProgramPath "%ProgramFiles%\Notepad++\notepad++.exe" -Extension .txt -Icon "%ProgramFiles%\Notepad++\notepad++.exe,0"
    }

    # Uninstall OneDrive
    OneDrive -Uninstall
    Remove-PossiblyMissingItem -Path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk" -Force

    # Enable ssh agent
    . "$PSScriptRoot/Components/SshAgent.ps1"

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

    # Sophia -Functions "Set-Association -ProgramPath `"C:\Program Files\Google\Chrome\Application\chrome.exe`" -Extension .html"
    # Sophia -Functions "Set-Association -ProgramPath `"C:\Program Files\Google\Chrome\Application\chrome.exe`" -Extension .htm"
    # Review: PinToStart
    # Review: UninstallUWPApps
    # Review: BackgroundUWPApps -Disable
    # Review: CheckUWPAppsUpdates
    # Review: GPUScheduling -Enable
    # Are these needed with storage sense enabled? TempTask -Register, SoftwareDistributionTask -Register, CleanupTask -Register

    DiagTrackService -Disable

    # Minimize diagnostic data collection
    New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection -Name AllowTelemetry -PropertyType DWord -Value 1 -Force
    New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection -Name MaxTelemetryAllowed -PropertyType DWord -Value 1 -Force
    New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack -Name ShowedToastAtLevel -PropertyType DWord -Value 1 -Force

    # Disable Error Reporting
    Get-ScheduledTask -TaskName QueueReporting | Disable-ScheduledTask
    New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" -Name Disabled -PropertyType DWord -Value 1 -Force
    Get-Service -Name WerSvc | Stop-Service -Force
    Get-Service -Name WerSvc | Set-Service -StartupType Disabled

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

    New-ItemProperty -Path HKLM:SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU -Name AllowMUUpdateService -PropertyType DWord -Value 1 -Force
    try {
        UpdateMicrosoftProducts -Enable
    }
    catch [System.Runtime.InteropServices.COMException] {
        $null
    }
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

    # Enable Network Protection
    if (-not (Test-Path -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows Defender")) {
        New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows Defender" -ItemType Directory -Force
    }
    if (-not (Test-Path -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard")) {
        New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard" -ItemType Directory -Force
    }
    if (-not (Test-Path -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\Network Protection")) {
        New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\Network Protection" -ItemType Directory -Force
    }
    New-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\Network Protection" -Name EnableNetworkProtection -PropertyType DWord -Value 1 -Force

    # Enable Potentially Unwanted Applications Protection
    if (-not (Test-Path -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows Defender")) {
        New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows Defender" -ItemType Directory -Force
    }
    if (-not (Test-Path -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows Defender\MpEngine")) {
        New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows Defender\MpEngine" -ItemType Directory -Force
    }
    New-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows Defender\MpEngine" -Name MpEnablePus -PropertyType DWord -Value 1 -Force

    # Enable Defender Sandboxing
    setx /M MP_FORCE_USE_SANDBOX 1

    if (-not (Test-Path -Path "HKCU:\SOFTWARE\Microsoft\Windows Security Health")) {
        New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows Security Health" -ItemType Directory -Force
    }
    if (-not (Test-Path -Path "HKCU:\SOFTWARE\Microsoft\Windows Security Health\State")) {
        New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows Security Health\State" -ItemType Directory -Force
    }
    DismissMSAccount
    DismissSmartScreenFilter

    WindowsScriptHost -Disable
    MSIExtractContext -Show
    CABInstallContext -Show
    MultipleInvokeContext -Enable
    RefreshEnvironment
    Errors
}

. $PSScriptRoot\Components\Common.ps1

Write-Verbose "Downloading Sophia Script"

$sophia = "$Downloads\Sophia.Script.v5.12.1.zip"
if (-Not (Test-Path $sophia )) {
    Start-BitsTransfer https://github.com/farag2/Sophia-Script-for-Windows/releases/download/5.12.1/Sophia.Script.v5.12.1.zip -Destination $Downloads
}

$sophiadir = "$env:TEMP\sophia"
$sophiaScript = "$sophiadir\Sophia Script v5.12.1"
try {
    Expand-Archive $sophia -DestinationPath $sophiadir -Force
    Invoke-Sophia $sophiascript
}
finally {
    Remove-PossiblyMissingItem $sophiadir -Recurse -Force
}

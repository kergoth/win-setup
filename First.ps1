# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
 
# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
 
# Check to see if we are currently running "as Administrator"
if (-Not $myWindowsPrincipal.IsInRole($adminRole))
{
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

Write-Verbose "Setting registry entries"
. "$PSScriptRoot/Components/Registry.ps1"

Write-Verbose "Enabling ssh agent"
. "$PSScriptRoot/Components/SshAgent.ps1"

# Install winget
if (-Not (Get-Command winget -ErrorAction SilentlyContinue))
{
    Write-Verbose "Installing winget"
    $vclibs = $env:TEMP + '/vclibs.appx'
    try {
        Invoke-WebRequest https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile $vclibs -UseBasicParsing
        Add-AppxPackage $vclibs
    }
    finally {
        Remove-Item $vclibs
    }

    $appinstaller = $env:TEMP + '/appinstaller.msixbundle'
    try {
        Invoke-WebRequest https://github.com/microsoft/winget-cli/releases/download/v1.0.11692/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle -OutFile $appinstaller -UseBasicParsing
        Add-AppxPackage $appinstaller
    }
    finally {
        Remove-Item $appinstaller
    }
}

# Install scoop
if (-Not (Get-Command scoop -ErrorAction SilentlyContinue))
{
    Write-Verbose "Installing scoop"
    Invoke-WebRequest -UseBasicParsing get.scoop.sh | Invoke-Expression
    $env:Path += ";" + $env:USERPROFILE + "/scoop/shims"
}

# Enable WSL, WSL 2, Sandbox
try {
    # Features don't work inside a Sandbox
    Get-WindowsOptionalFeature -Online -ErrorAction SilentlyContinue | Out-Null
    if (-Not $error)
    {
        Write-Verbose "Enabling WSL"

        # Enable WSL
        $feature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
        if (-Not $feature)
        {
            Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -All -NoRestart
        }

        # Enable Virtual Machine Platform for WSL 2
        $feature = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
        if (-Not $feature)
        {
            Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All -NoRestart
        }

        # Enable Windows Sandbox
        $feature = Get-WindowsOptionalFeature -Online -FeatureName Containers-DisposableClientVM
        if (-Not $feature)
        {
            Enable-WindowsOptionalFeature -Online -FeatureName Containers-DisposableClientVM -All -NoRestart
        }
    }
}
catch {
}

# Attempt to drop elevated rights
# # Create a new process object that starts PowerShell
# $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";

# # Start the new process
# [System.Diagnostics.Process]::Start($newProcess);

# # Exit from the current, elevated, process
# exit

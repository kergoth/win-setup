# Function Test-RegistryValue($regkey, $name) {
#     Get-ItemProperty $regkey $name -ErrorAction SilentlyContinue | Out-Null
#     $?
# }

function Test-RegistryValue {

param (

 [parameter(Mandatory=$true)]
 [ValidateNotNullOrEmpty()]$Path,

[parameter(Mandatory=$true)]
 [ValidateNotNullOrEmpty()]$Value
)

try {

Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Value -ErrorAction Stop | Out-Null
 return $true
 }

catch {

return $false

}

}


Function Set-ItemPropertyReally {
param (

 [parameter(Mandatory=$true)]
 [ValidateNotNullOrEmpty()]$Path,

[parameter(Mandatory=$true)]
 [ValidateNotNullOrEmpty()]$Property,

 [parameter(Mandatory=$true)]
 [ValidateNotNullOrEmpty()]$Type,

 [parameter(Mandatory=$true)]
 [ValidateNotNullOrEmpty()]$Value
)
    if (Test-RegistryValue -Path $Path -Value $Property) {
        Set-ItemProperty $Path -Name $Property -Type $Type -Value $Value
    } else {
        New-ItemProperty $Path -Name $Property -PropertyType $Type -Value $Value
    }
}

# Enable app sideloading
Set-ItemPropertyReally -Path HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock -Property AllowAllTrustedApps -Type DWord -Value 1 | Out-Null

# Enable windows developer mode
Set-ItemPropertyReally -Path HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock -Property AllowDevelopmentWithoutDevLicense -Type DWord -Value 1 | Out-Null

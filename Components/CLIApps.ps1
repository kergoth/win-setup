. $PSScriptRoot\Components\Common.ps1

# Install command-line tools

# # Quicker downloads
# scoop install aria2

# Utilities
scoop install sudo git gh bat delta gow

# Editor
scoop install neovim

# Powershell
scoop install starship

# Languages
scoop install go rust python
$reg = Get-ChildItem $env:USERPROFILE\scoop\apps\python\*\install-pep-514.reg -ErrorAction SilentlyContinue | Select-Object -First 1
if ($reg) {
    Write-Host "Importing python registry entries"
    reg import $reg
}

# Refresh $env:PATH
RefreshEnvPath

# More utilities
cargo install fd-find ripgrep
cargo install --git https://github.com/jez/as-tree
cargo install --no-default-features --branch chesterliu/dev/win-support --git https://github.com/skyline75489/exa

# Extra scoop apps
scoop bucket add extras

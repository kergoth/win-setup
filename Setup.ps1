# Initial setup
powershell .\First.ps1

# Add scoop to the PATH
$env:Path += ";" + $env:USERPROFILE + "/scoop/shims"

# Install command-line tools

# Quicker downloads
scoop install aria2

# Utilities
scoop install sudo git gh bat delta gow

# Editor
scoop install neovim

# Powershell
scoop install starship

# Languages
scoop install go rust

# More utilities
cargo install fd-find ripgrep
cargo install --git https://github.com/jez/as-tree
cargo install --no-default-features --branch chesterliu/dev/win-support --git https://github.com/skyline75489/exa

# Extra scoop apps
scoop bucket add extras

# Install applications
winget import winget.json

# Configure
powershell .\Configure.ps1

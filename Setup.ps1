# Initial setup
powershell .\First.ps1

# Install command-line tools

# Quicker downloads
scoop install aria2

# Utilities
scoop install sudo git gh bat delta gow
cargo install fd-find ripgrep
cargo install --git https://github.com/jez/as-tree
cargo install --no-default-features --branch chesterliu/dev/win-support --git https://github.com/skyline75489/exa

# Editor
scoop install neovim

# Powershell
scoop install starship

# Languages
scoop install go rust

# Extra scoop apps
scoop bucket add extras

# Install applications
winget install powertoys --silent
winget install quicklook --silent
winget install terminal --silent
winget install synctrayzor --silent
winget install notepad++ --silent

winget install 1password --silent
winget install autohotkey --silent
winget install vivaldi --silent
winget install discord --silent

winget install rufus --silent
winget install putty --silent
winget install vscode --silent
winget install slack --silent
winget install powershell --silent

# HexChat's installer likes to pop up an error running vcredist, so run it last
winget install hexchat --silent

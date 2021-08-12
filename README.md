# Windows 10 Setup

## General Notes

- bat installs fine through scoop but fails through cargo
- fd-find, ripgrep install fine through cargo
- Available in scoop: fd, ripgrep, delta
- Not available in scoop, and fails in cargo: exa, git-series
  - Windows support for exa is in-progress at <https://github.com/ogham/exa/pull/820>

## Manual Steps

- Set up all my Syncthing shares
- Restore from backup:
  - `$USERPROFILE/Apps`
  - Vivaldi: `AppData/Local/Vivaldi/User Data/Default/`
  - HexChat: `AppData/Roaming/HexChat`
  - archwsl disk image
- Run QuickLook, right click its icon, click start at login
- Create link to CapsLockCtrlEscape.exe in Startup (win-r -> shell:startup)
- Install Fonts from Sync/Fonts
- Run vscode, enable settings sync

### Work Machines

- Get logged in for Outlook, MS Teams, MS Store
- Run Software Center, install VMware

### Task Bar

- Add Vivaldi, Outlook, Slack, Discord, HexChat, Terminal, Vscode, Rufus, Putty to task bar pins.
- Set anyconnect to always show for notification icons

## TODO

- Determine how to avoid reinstalling winget items if they're already installed. Wrapper script?
- See about adding the 7-zip install path to the PATH, it doesn't seem to be by default. I can install 7-zip in scoop, but then I have a second install of its gui as well, better to add the existing path to my PATH.
- Test use of individual projects rather than `gow`, ex. coreutils grep sed less
- Determine what I need to run at least once to get them to add themselves to
  the Startup. PowerToys? 1Password seems to both set itself up and run itself. Check startup items.
- Determine if I can configure print screen to do the same thing as
  win+shift+s by opening Snip & Sketch

### Add to setup script

- Run hyper-v-fix-for-devs script
- Run an elevated wsl terminal, clone dotfiles into $USERPROFILE/dotfiles, run:

```console
./script/install -d $USERPROFILE -f windows-terminal powershell git`
```

- Run ssh-add in powershell to add my key to the agent, if it exists

### Create settings script based on github projects

- Remove Edge, Store, Mail from the task bar pins.
- Figure out how to pin items to the task bar from powershell

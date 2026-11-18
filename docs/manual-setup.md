# Manual setup

Settings that can't be managed through the dotfiles and have to be configured by hand on each Fedora KDE machine.

## System Settings

- Enable auto-login:
  - "Login Screen": Enable auto-login
  - In KWalletManager, set the password to empty
- Under "Window Management" → "Task Switcher": Disable "Show selected window"
- "Screen Locking":
  - Set "Delay before password required" to "Require password immediately"
  - Click "Configure Appearance...", set "Wallpaper type" to "Plain Color", and select black
- "Wallpaper":
  - Enable "Set for all screens"
  - Set "Wallpaper type" to "Plain Color" and select black
- Under "Display & Monitor" → "Screen Edges":
  - Disable "Corner barrier" and set "Edge barrier" to 0
  - Disable screen edge actions
- "Region & Language": Set everything except "Language" and "Data and Storage Sizes" to default German
- "Keyboard": Set "NumLock on startup" to "Turn on"
- "Autostart": Click "Add new", select "Application", type `krunner -d`, and confirm

## Taskbar

- Configure the taskbar on the primary screen:
  - Right-click the taskbar and click "Show Panel Configuration":
    - Set "Floating" to "Disabled"
    - Remove the "Peek at Desktop" widget on the right
  - Right-click the taskbar and click "Configure Icons-Only Task Manager":
    - "Appearance": Disable "Mute task when clicking indicator"
    - "Behavior": Set "Clicking grouped task" to "Shows small window previews"
- Configure the taskbar on secondary screen(s):
  - Right-click the taskbar, click "Show Panel Configuration", click "Clone Panel", and press the downwards arrow on the secondary screen
  - Click on the new taskbar and remove the "System Tray" widget

## Applications

### KeePassXC

In the application settings:

- "Security":
  - Disable "Lock databases after inactivity of"
  - Disable "Enable database quick unlock (Touch ID / Windows Hello)"
- "Browser Integration":
  - Enable "Enable browser integration"
  - Enable "Search in all opened databases for matching credentials"

### KRunner

Open KRunner (`alt` + `space`), click "Configure KRunner...", click "Configure Enabled Search Plugins...", and unfavorite System Settings.

### KWrite

- Open KWrite and disable "Show welcome page for new window"
- In the settings, under "Appearance" → "General", disable "Dynamic Word Wrap"

### Dolphin

- Settings → "Interface" → "Folders & Tabs": Set "Show on startup" to `/home/jkemming`
- Press `Ctrl` + `3` to switch to Detail View and zoom out to maximum

### Konsole

- Right-click and go to "Menu" → "Settings" → "Toolbars Shown". There, disable all items.
- Right-click and go to "Menu" → "Settings" → "Configure Konsole":
  - "Tab Bar / Splitters" → "Behavior": Enable "Close tab on middle-click"
  - "Profiles": Create a new profile:
    - "General":
      - Name: "fish"
      - Enable "Default profile"
      - Command: `/usr/bin/fish`
    - "Tabs":
      - Tab title format: `%w`
    - "Appearance":
      - Uncheck "Draw intense colors in bold font"

## Video codecs

1. [Enable RPM Fusion repositories](https://docs.fedoraproject.org/en-US/quick-docs/rpmfusion-setup/):

   ```shell
   sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
   sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
   sudo dnf update
   ```

2. [Install packages](https://docs.fedoraproject.org/en-US/quick-docs/installing-plugins-for-playing-movies-and-music/):

   ```shell
   sudo dnf group install multimedia
   ```

3. Restart

## Epson ET-2500 printer

1. Download the driver from [Epson](https://download-center.epson.com/softwares/?device_id=ET-2710+Series&region=DE&os=RPM&language=en)
2. Install it:

   ```shell
   sudo rpm --nodigest --nofiledigest -i ~/Downloads/epson-inkjet-printer-escpr-1.8.6-1.x86_64.rpm
   ```

## Bluetooth headphones with Windows dual boot

To use the same Bluetooth headphones on both systems, Fedora needs the pairing key Windows generated.

1. Connect the headphones to Fedora
2. Get the relevant MAC addresses:
   - Run `bluetoothctl list` to get the adapter's address (currently `A8:6E:84:87:86:93`)
   - Run `bluetoothctl devices` to get the headset's address (currently `AC:80:0A:A2:24:C6`)
3. Connect the headphones to Windows
4. Get the pairing key from Windows:
   1. Download [Sysinternals PsExec](https://learn.microsoft.com/en-us/sysinternals/downloads/psexec) and extract it to `D:\Windows\Downloads\PSTools`
   2. Open Command Prompt as admin and run `D:\Windows\Downloads\PSTools\PsExec.exe -i -s powershell.exe` to get a shell with system level permissions
   3. In the system level shell, run:

      ```shell
      reg export "HKLM\SYSTEM\CurrentControlSet\Services\BTHPORT\Parameters\Keys" D:\Windows\Downloads\export.txt
      ```

   4. The output should contain the following lines:

      ```
      [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\BTHPORT\Parameters\Keys\${adapter_mac}]
      "${headset_mac}"=hex:${pairing_key}
      ```

5. Replace the pairing key in Fedora:
   1. Format the exported pairing key to upper case without spaces (e.g. `027ED04F12498A1BACA9D98CAE3DE71B`)
   2. Run `sudo nano /var/lib/bluetooth/${adapter_mac}/${headset_mac}/info`
   3. Replace the key in the line starting with `Key=` and save
   4. Restart

## Troubleshooting

### Videos no longer load in browsers

The sound drivers probably crashed. Restart them:

```shell
systemctl --user restart pipewire pipewire-pulse wireplumber
```

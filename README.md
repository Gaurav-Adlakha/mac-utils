# mac-utils

macOS menu bar utilities for power users.

---

## Chrome Profile Switcher

Switch between Chrome profiles directly from the macOS menu bar. Any link you click in Slack, Mail, or any other app automatically opens in whichever Chrome profile you have selected.

### How it works

```
You click a link in Slack / Mail / anywhere
            ↓
ChromeRouter intercepts it (set as your default browser)
            ↓
ChromeRouter reads ~/.chrome_active_profile
            ↓
Opens the URL in Chrome with the correct profile
```

The menu bar shows your active profile at all times. Click it to switch.

---

### What gets installed

| Tool | Purpose |
|---|---|
| **Homebrew** | macOS package manager — used to install everything else |
| **SwiftBar** | Runs shell scripts as clickable menu bar items |
| **Finicky** | Acts as the default browser and routes links to the right Chrome profile |
| **ChromeRouter.app** | AppleScript app (compiled from `chrome_router.applescript`) — the actual URL handler Finicky calls |
| **chrome_profiles.1h.sh** | SwiftBar plugin — reads Chrome's Local State, shows profiles in menu bar, handles switching |

---

### Prerequisites

- macOS (tested on macOS Sequoia)
- Google Chrome installed at `/Applications/Google Chrome.app`
- Python 3 (comes with macOS or install via Homebrew)

---

### Installation

#### Step 1 — Install Homebrew

If you don't have Homebrew installed:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### Step 2 — Install SwiftBar

```bash
brew install --cask swiftbar
```

#### Step 3 — Install Finicky

```bash
brew install --cask finicky
```

#### Step 4 — Create the SwiftBar plugins folder

```bash
mkdir -p ~/swiftbar-plugins
```

#### Step 5 — Copy the SwiftBar plugin

```bash
cp chrome_profiles.1h.sh ~/swiftbar-plugins/
chmod +x ~/swiftbar-plugins/chrome_profiles.1h.sh
```

#### Step 6 — Compile ChromeRouter.app

This step turns the AppleScript source into a macOS app that can act as a URL handler:

```bash
osacompile -o ~/Applications/ChromeRouter.app chrome_router.applescript
```

Then set its bundle identifier so macOS recognises it as a browser:

```bash
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes array" ~/Applications/ChromeRouter.app/Contents/Info.plist 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0 dict" ~/Applications/ChromeRouter.app/Contents/Info.plist
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLName string ChromeRouter" ~/Applications/ChromeRouter.app/Contents/Info.plist
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes array" ~/Applications/ChromeRouter.app/Contents/Info.plist
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes:0 string http" ~/Applications/ChromeRouter.app/Contents/Info.plist
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes:1 string https" ~/Applications/ChromeRouter.app/Contents/Info.plist
/usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string com.local.chromerouter" ~/Applications/ChromeRouter.app/Contents/Info.plist 2>/dev/null || \
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.local.chromerouter" ~/Applications/ChromeRouter.app/Contents/Info.plist
```

Register it with macOS:

```bash
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
  -f ~/Applications/ChromeRouter.app
```

#### Step 7 — Configure Finicky

Create `~/.finicky.js` with the following content:

```javascript
module.exports = {
  defaultBrowser: "ChromeRouter",
  handlers: []
};
```

#### Step 8 — Set Finicky as your default browser

1. Open **Finicky** from your Applications folder
2. Click **"Use Finicky"** when macOS asks to confirm the default browser change
3. Finicky will now intercept every link click and pass it to ChromeRouter

#### Step 9 — Set up SwiftBar

1. Open **SwiftBar** from your Applications folder
2. When it asks **"Choose plugin folder"**, navigate to your home folder and select `swiftbar-plugins`
3. Click **Open**

You should now see your active Chrome profile name (e.g. `🌐 pendo.io`) in your menu bar.

---

### Usage

**Switch profiles:**
Click the `🌐 profile name` item in the menu bar → click any profile in the dropdown.

**Open links in the active profile:**
Just click any link anywhere (Slack, Mail, Notes, Terminal). It will open in Chrome using the profile currently shown in your menu bar.

---

### Customization

#### Hide a profile from the menu bar

Edit `~/swiftbar-plugins/chrome_profiles.1h.sh` and add the profile's folder key to the `HIDDEN` list:

```bash
HIDDEN=['Profile 3', 'Profile 5']
```

To find the folder key for a profile, run:

```bash
python3 -c "
import json
with open('$HOME/Library/Application Support/Google/Chrome/Local State') as f:
    d = json.load(f)
for k, v in d['profile']['info_cache'].items():
    print(k, '->', v.get('name'), '/', v.get('user_name'))
"
```

#### Change the refresh interval

The filename `chrome_profiles.1h.sh` tells SwiftBar to refresh every 1 hour. Rename it to change the interval:

| Filename | Refresh interval |
|---|---|
| `chrome_profiles.10s.sh` | Every 10 seconds |
| `chrome_profiles.1m.sh` | Every 1 minute |
| `chrome_profiles.1h.sh` | Every 1 hour |

---

### File reference

| File | Location after install | Purpose |
|---|---|---|
| `chrome_profiles.1h.sh` | `~/swiftbar-plugins/` | SwiftBar plugin |
| `chrome_router.applescript` | source only | AppleScript source for ChromeRouter |
| `ChromeRouter.app` | `~/Applications/` | Compiled URL handler app |
| `~/.chrome_active_profile` | auto-created | Stores the currently selected profile key |
| `~/.finicky.js` | `~/` | Finicky config — routes all links to ChromeRouter |

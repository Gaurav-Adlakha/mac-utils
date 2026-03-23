#!/bin/bash
# SwiftBar Chrome Profile Switcher
# Reads Chrome's Local State JSON to list profiles and lets you switch between them.

CHROME_LOCAL_STATE="$HOME/Library/Application Support/Google/Chrome/Local State"
CHROME_BIN="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

# --- Get current default profile key and name ---
CURRENT_KEY=$(python3 -c "
import json
with open('$CHROME_LOCAL_STATE') as f:
    d = json.load(f)
print(d['profile'].get('last_used', ''))
")

CURRENT_NAME=$(python3 -c "
import json
with open('$CHROME_LOCAL_STATE') as f:
    d = json.load(f)
profiles = d['profile']['info_cache']
key = d['profile'].get('last_used', '')
print(profiles.get(key, {}).get('name', 'Chrome'))
")

# --- Menu bar title (what you see in the top bar) ---
echo "🌐 $CURRENT_NAME"
echo "---"

# --- List all profiles ---
python3 -c "
import json, subprocess, sys
with open('$CHROME_LOCAL_STATE') as f:
    d = json.load(f)
profiles = d['profile']['info_cache']
current = d['profile'].get('last_used', '')

HIDDEN = ['Profile 3']
for key, info in profiles.items():
    if key in HIDDEN:
        continue
    name = info.get('name', 'Unknown')
    email = info.get('user_name', '')
    label = f'{name}  ({email})' if email else name
    check = '✅ ' if key == current else '   '
    # SwiftBar bash action: clicking this item runs the switch command
    print(f'{check}{label} | bash=\"/Users/gaurav/swiftbar-plugins/chrome_profiles.1h.sh\" param1=switch param2=\"{key}\" terminal=false refresh=true')
"

echo "---"
echo "Refresh | refresh=true"

# --- Handle switch action (called when a menu item is clicked) ---
if [ "$1" = "switch" ]; then
    PROFILE_KEY="$2"

    # Step 1: Set this profile as the new default in Local State
    python3 -c "
import json
path = '$CHROME_LOCAL_STATE'
with open(path) as f:
    d = json.load(f)
d['profile']['last_used'] = '$PROFILE_KEY'
with open(path, 'w') as f:
    json.dump(d, f, indent=2)
print('Switched to: $PROFILE_KEY')
"

    # Step 2: Also update the active profile file (ChromeRouter reads this on every link click)
    echo "$PROFILE_KEY" > ~/.chrome_active_profile

    # Step 3: Open Chrome with the selected profile
    open -a "Google Chrome" --args --profile-directory="$PROFILE_KEY"
fi

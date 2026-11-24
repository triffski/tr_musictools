#!/bin/bash
# Backs up Ableton Live 12 themes (*.ask) into a timestamped subfolder inside a
# folder you pick via a GUI dialog.

set -euo pipefail

SRC="/Applications/Ableton Live 12 Suite.app/Contents/App-Resources/Themes"

if [ ! -d "$SRC" ]; then
  osascript -e 'display alert "Ableton not found" message "Could not find App-Resources. Check the Live 12 version/install path." as critical'
  exit 1
fi

PARENT=$(osascript -e 'POSIX path of (choose folder with prompt "Choose where to save the themes backup")' 2>/dev/null) || exit 0

STAMP=$(date +%Y-%m-%d_%H-%M-%S)
DEST="${PARENT}ableton-themes_${STAMP}"
mkdir -p "$DEST"

shopt -s nullglob
ask_files=("$SRC"/*.ask)

if [ ${#ask_files[@]} -eq 0 ]; then
  osascript -e 'display alert "Nothing to back up" message "No .ask theme files found in the app."'
  exit 1
fi

cp "${ask_files[@]}" "$DEST"/
echo "Backed up ${#ask_files[@]} theme(s) to:"
echo "$DEST"
osascript -e "display notification \"${#ask_files[@]} themes backed up.\" with title \"Ableton themes:\""

#!/bin/bash
# Restores Ableton Live 12 themes (*.ask) from a folder you pick into the app's
# Themes folder. Lists every theme found (with version) for review, then asks
# how to handle overwrites.

set -euo pipefail

DEST="/Applications/Ableton Live 12 Suite.app/Contents/App-Resources/Themes"

# Stock default theme names, from the clean Live 12.4.16 Suite installer.
DEFAULTS=(
  "Angst Robot"
  "Classic Medium Dark"
  "Classic Medium Light"
  "Default Dark Cool High"
  "Default Dark Cool Medium"
  "Default Dark Neutral High"
  "Default Dark Neutral Medium"
  "Default Dark Warm High"
  "Default Dark Warm Medium"
  "Default Light Cool High"
  "Default Light Cool Medium"
  "Default Light Neutral High"
  "Default Light Neutral Medium"
  "Default Light Warm High"
  "Default Light Warm Medium"
  "Immaterial"
  "Riparian"
  "Twenty-Four Carat"
)

is_default() {
  local n="${1%.ask}"
  for d in "${DEFAULTS[@]}"; do [ "$n" = "${d%.ask}" ] && return 0; done
  return 1
}

if [ ! -d "$DEST" ]; then
  osascript -e 'display alert "Ableton not found" message "Could not find the Themes folder. Check the Live 12 version/install path." as critical'
  exit 1
fi

SRC=$(osascript -e 'POSIX path of (choose folder with prompt "Choose the themes backup folder to restore from")' 2>/dev/null) || exit 0

shopt -s nullglob
ask_files=("$SRC"*.ask)
if [ ${#ask_files[@]} -eq 0 ]; then
  osascript -e 'display alert "Nothing to restore" message "No .ask theme files found in the chosen folder."'
  exit 1
fi

# Detect the Live version a theme was authored for.
theme_version() {
  local f="$1" major root
  major=$(grep -m1 -oE 'MinorVersion="[0-9]+' "$f" | grep -oE '[0-9]+$' || true)
  if [ -n "$major" ]; then
    echo "Live $major"; return
  fi
  root=$(grep -m1 -oE '<(SkinManager|Theme)' "$f" || true)
  case "$root" in
    "<Theme") echo "Live 12" ;;
    "<SkinManager") echo "Live 10/11" ;;
    *) echo "unknown" ;;
  esac
}

# Build the review list + counts.
list=""
n12=0; nold=0
for f in "${ask_files[@]}"; do
  base=$(basename "$f" .ask)
  ver=$(theme_version "$f")
  if [ "$ver" = "Live 12" ]; then
    n12=$((n12+1))
    list+="[12]  $base"$'\n'
  else
    nold=$((nold+1))
    list+="[${ver#Live }]  $base  - pre-12 format"$'\n'
  fi
done
list=${list%$'\n'}

header="${#ask_files[@]} themes found  -  ${n12} x Live 12, ${nold} x older"

# Show the list for review (scrollable); Continue proceeds, Cancel aborts.
go=$(osascript <<OSA 2>/dev/null
set theLines to paragraphs of "$list"
set chosen to choose from list theLines with title "Ableton themes:" with prompt "$header" OK button name "Continue" cancel button name "Cancel" without multiple selections allowed and empty selection allowed
if chosen is false then return "CANCEL"
return "GO"
OSA
) || exit 0
[ "$go" = "GO" ] || exit 0

# How to handle files that already exist in the destination.
choice=$(osascript -e 'button returned of (display dialog "Overwrite themes already in the Ableton folder?" with title "Ableton themes:" buttons {"None", "Custom only", "Replace all"} default button "None")' 2>/dev/null) || exit 0

to_copy=()
for f in "${ask_files[@]}"; do
  base=$(basename "$f")
  case "$choice" in
    "None")        [ -e "$DEST/$base" ] && continue ;;   # add missing only
    "Custom only") is_default "$base" && continue ;;      # skip stock defaults
    "Replace all") : ;;                                   # everything
  esac
  to_copy+=("$f")
done

if [ ${#to_copy[@]} -eq 0 ]; then
  echo "Nothing to do - no themes copied."
  exit 0
fi

if cp -f "${to_copy[@]}" "$DEST"/ 2>/dev/null; then
  :
else
  osascript -e 'display alert "Permission needed" message "Writing to the app bundle needs admin rights. A password prompt will follow in Terminal." as warning'
  sudo cp -f "${to_copy[@]}" "$DEST"/
fi

echo ""
echo "Restored ${#to_copy[@]} theme(s)."
echo "Restart Ableton to see newly installed themes."

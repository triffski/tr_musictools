# ableton-theme-backup-restore

Back up and restore your Ableton Live 12 themes (`*.ask`) around updates and reinstalls, which wipe the app's Themes folder. macOS (`.command`) and Windows (`.bat` + `.ps1`) versions, functionally identical.

- **backup** - copies every theme from Live's Themes folder into a timestamped subfolder of a folder you pick
- **restore** - copies themes from a folder you pick back into Live, listing each one with its detected Live version, then asking how to handle overwrites: **None** (add missing only), **Custom only** (skip the stock defaults), or **Replace all**

---

## usage

**macOS** - double-click `ableton-themes-backup.command` / `ableton-themes-restore.command` (right-click > Open the first time, or run with `bash` if Gatekeeper blocks a downloaded copy).

**Windows** - double-click `ableton-themes-backup.bat` / `ableton-themes-restore.bat` (they run the matching `.ps1` with the execution policy bypassed for that one run). Restore may raise a UAC prompt when writing into the install.

Quit Live before restoring; restart it afterwards to see new themes.

---

## notes

- **Themes folder** is found automatically: `…/Ableton Live 12 Suite.app/Contents/App-Resources/Themes` on macOS, `C:\ProgramData\Ableton\Live 12 *\Resources\Themes` on Windows. For a non-Suite edition on macOS, edit the path near the top of the script
- **Never deletes** anything - restore only adds or overwrites
- **Version tags** in restore come from each theme's `MinorVersion` / root tag, so you can spot pre-12 themes before copying them in

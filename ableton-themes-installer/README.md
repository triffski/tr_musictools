# ableton-themes-installer

A bash script that puts your custom Ableton Live 12 themes back after an Ableton update or reinstall wipes them out.

Keep your downloaded themes in a folder outside the app, drop this script in the same folder, and run it whenever the themes go missing. It copies everything in that folder into Live's Themes folder.

macOS only.

---

## usage

- Put `ableton-themes-installer.command` in your themes folder
- Quit Live
- Run it: double-click in Finder, right-click > Open, or `bash ableton-themes-installer.command` from that folder

---

## what it does

- **Copies** every file in its own folder into `/Applications/Ableton Live 12 Suite.app/Contents/App-Resources/Themes`, except itself
- **Refuses to run** if Live is open, or if the Themes folder isn't found
- **Retries with sudo** if the copy is denied
- **Overwrites** themes of the same name; never deletes anything

---

## notes

- **Suite only as written.** For Standard or Intro, edit `DEST` near the top of the script to match your app name
- **macOS 26 Gatekeeper** - a copy downloaded through a browser or as a ZIP can refuse to run when double-clicked, even after `chmod +x` and `xattr -c`. That's macOS's `com.apple.provenance` flag, not a permissions fault. Cloning with git avoids the flag; right-click > Open or running it with `bash` gets round it either way

---

Provided as-is. Back up your themes folder first.

# Backs up Ableton Live 12 themes (*.ask) into a timestamped subfolder inside a
# folder you pick via a GUI dialog. Windows port of ableton-themes-backup.command.

Add-Type -AssemblyName System.Windows.Forms

function Find-ThemesFolder {
  foreach ($base in @("$env:ProgramData\Ableton", "$env:ProgramFiles\Ableton")) {
    if (Test-Path $base) {
      $hit = Get-ChildItem -Path $base -Directory -Filter "Live 12*" -ErrorAction SilentlyContinue |
             ForEach-Object { Join-Path $_.FullName "Resources\Themes" } |
             Where-Object { Test-Path $_ } | Select-Object -First 1
      if ($hit) { return $hit }
    }
  }
  return $null
}

$SRC = Find-ThemesFolder
if (-not $SRC) {
  [System.Windows.Forms.MessageBox]::Show("Could not find the Live 12 Themes folder. Check the version/install path.", "Ableton not found", 'OK', 'Error') | Out-Null
  exit 1
}

$dlg = New-Object System.Windows.Forms.FolderBrowserDialog
$dlg.Description = "Choose where to save the themes backup"
if ($dlg.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) { exit 0 }
$PARENT = $dlg.SelectedPath

$ask = @(Get-ChildItem -Path $SRC -Filter *.ask -File -ErrorAction SilentlyContinue)
if ($ask.Count -eq 0) {
  [System.Windows.Forms.MessageBox]::Show("No .ask theme files found in the app.", "Nothing to back up", 'OK', 'Warning') | Out-Null
  exit 1
}

$stamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$DEST = Join-Path $PARENT "ableton-themes_$stamp"
New-Item -ItemType Directory -Path $DEST -Force | Out-Null
$ask | Copy-Item -Destination $DEST -Force

[System.Windows.Forms.MessageBox]::Show("$($ask.Count) theme(s) backed up to:`n$DEST", "Ableton themes", 'OK', 'Information') | Out-Null

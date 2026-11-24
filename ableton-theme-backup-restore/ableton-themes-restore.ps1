# Restores Ableton Live 12 themes (*.ask) from a folder you pick into the app's
# Themes folder. Lists every theme found (with version) for review, then asks how
# to handle overwrites. Windows port of ableton-themes-restore.command.

Add-Type -AssemblyName System.Windows.Forms

# Stock default theme names, from the clean Live 12.4.16 Suite installer.
$DEFAULTS = @(
  "Angst Robot","Classic Medium Dark","Classic Medium Light",
  "Default Dark Cool High","Default Dark Cool Medium","Default Dark Neutral High","Default Dark Neutral Medium",
  "Default Dark Warm High","Default Dark Warm Medium",
  "Default Light Cool High","Default Light Cool Medium","Default Light Neutral High","Default Light Neutral Medium",
  "Default Light Warm High","Default Light Warm Medium",
  "Immaterial","Riparian","Twenty-Four Carat"
)
function Test-IsDefault([string]$name) { $DEFAULTS -contains [IO.Path]::GetFileNameWithoutExtension($name) }

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

# Detect the Live version a theme was authored for.
function Get-ThemeVersion([string]$path) {
  $txt = (Get-Content -LiteralPath $path -TotalCount 40 -ErrorAction SilentlyContinue) -join "`n"
  if ($txt -match 'MinorVersion="(\d+)') { return "Live $($Matches[1])" }
  if ($txt -match '<Theme')       { return "Live 12" }
  if ($txt -match '<SkinManager') { return "Live 10/11" }
  return "unknown"
}

$DEST = Find-ThemesFolder
if (-not $DEST) {
  [System.Windows.Forms.MessageBox]::Show("Could not find the Live 12 Themes folder. Check the version/install path.", "Ableton not found", 'OK', 'Error') | Out-Null
  exit 1
}

$dlg = New-Object System.Windows.Forms.FolderBrowserDialog
$dlg.Description = "Choose the themes backup folder to restore from"
if ($dlg.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) { exit 0 }
$SRC = $dlg.SelectedPath

$ask = @(Get-ChildItem -Path $SRC -Filter *.ask -File -ErrorAction SilentlyContinue)
if ($ask.Count -eq 0) {
  [System.Windows.Forms.MessageBox]::Show("No .ask theme files found in the chosen folder.", "Nothing to restore", 'OK', 'Warning') | Out-Null
  exit 1
}

# Build the review list + counts.
$n12 = 0; $nold = 0
$rows = foreach ($f in $ask) {
  $ver = Get-ThemeVersion $f.FullName
  if ($ver -eq "Live 12") { $n12++ } else { $nold++ }
  $note = if ($ver -ne "Live 12") { "pre-12 format" } else { "" }
  [PSCustomObject]@{ Version = $ver; Theme = [IO.Path]::GetFileNameWithoutExtension($f.Name); Note = $note }
}

# Show the list for review (scrollable), then confirm.
$rows | Out-GridView -Title "Ableton themes: $($ask.Count) found  -  $n12 x Live 12, $nold x older  (close to continue)" -Wait
$go = [System.Windows.Forms.MessageBox]::Show("Continue restoring $($ask.Count) theme(s) into Live?", "Ableton themes", 'OKCancel', 'Question')
if ($go -ne [System.Windows.Forms.DialogResult]::OK) { exit 0 }

# How to handle files that already exist in the destination.
function Select-Policy {
  $form = New-Object System.Windows.Forms.Form
  $form.Text = "Ableton themes"; $form.Width = 380; $form.Height = 150
  $form.StartPosition = "CenterScreen"; $form.FormBorderStyle = 'FixedDialog'
  $form.MaximizeBox = $false; $form.MinimizeBox = $false
  $lbl = New-Object System.Windows.Forms.Label
  $lbl.Text = "Overwrite themes already in the Ableton folder?"
  $lbl.AutoSize = $true; $lbl.Top = 18; $lbl.Left = 18; $form.Controls.Add($lbl)
  $script:policy = $null
  foreach ($opt in @(@("None",18), @("Custom only",128), @("Replace all",248))) {
    $b = New-Object System.Windows.Forms.Button
    $b.Text = $opt[0]; $b.Left = $opt[1]; $b.Top = 60; $b.Width = 105
    $b.Add_Click({ $script:policy = $this.Text; $form.Close() })
    $form.Controls.Add($b)
  }
  [void]$form.ShowDialog()
  return $script:policy
}
$choice = Select-Policy
if (-not $choice) { exit 0 }

$toCopy = foreach ($f in $ask) {
  $skip = $false
  if     ($choice -eq "None"        -and (Test-Path (Join-Path $DEST $f.Name))) { $skip = $true }  # add missing only
  elseif ($choice -eq "Custom only" -and (Test-IsDefault $f.Name))              { $skip = $true }  # skip stock defaults
  if (-not $skip) { $f }                                                                           # Replace all -> never skips
}
$toCopy = @($toCopy)

if ($toCopy.Count -eq 0) {
  [System.Windows.Forms.MessageBox]::Show("Nothing to do - no themes copied.", "Ableton themes", 'OK', 'Information') | Out-Null
  exit 0
}

try {
  $toCopy | Copy-Item -Destination $DEST -Force -ErrorAction Stop
} catch {
  # Writing into the install may need admin - retry the copy elevated.
  [System.Windows.Forms.MessageBox]::Show("Writing to the Ableton folder needs admin rights. A UAC prompt will follow.", "Permission needed", 'OK', 'Warning') | Out-Null
  $cmds = ($toCopy | ForEach-Object { "Copy-Item -LiteralPath `"$($_.FullName)`" -Destination `"$DEST`" -Force" }) -join "; "
  Start-Process powershell -Verb RunAs -Wait -ArgumentList "-NoProfile","-Command",$cmds
}

[System.Windows.Forms.MessageBox]::Show("Restored $($toCopy.Count) theme(s).`nRestart Ableton to see newly installed themes.", "Ableton themes", 'OK', 'Information') | Out-Null

@echo off
rem Double-click launcher - runs the PowerShell restore script next to it.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0ableton-themes-restore.ps1"

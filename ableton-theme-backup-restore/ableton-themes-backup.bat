@echo off
rem Double-click launcher - runs the PowerShell backup script next to it.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0ableton-themes-backup.ps1"

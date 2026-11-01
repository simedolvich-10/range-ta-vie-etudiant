@echo off
powershell.exe -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "%~dp0serve-site.ps1" -StartSite
if errorlevel 1 (
  echo.
  echo Le site n'a pas pu demarrer. Consulte le message ci-dessus.
  pause
)

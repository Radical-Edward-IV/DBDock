@echo off
chcp 65001 > nul
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& {Set-Location '%~dp0'; ./dbms-image-load.ps1}"
pause
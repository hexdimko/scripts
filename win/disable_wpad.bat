@echo off
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" /v AutoDetect /t REG_DWORD /d 0
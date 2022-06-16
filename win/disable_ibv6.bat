@echo off
powershell -command "Get-NetAdapterBinding -ComponentID 'ms_tcpip6' | Where-Object{$_.enabled -eq 'True'} | Disable-NetAdapterBinding"
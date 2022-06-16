$Interface = Get-NetAdapterBinding -ComponentID "ms_tcpip6"
foreach ($int in $Interface)
{
if ($int.enabled -eq "True")
{
Disable-NetAdapterBinding -InterfaceAlias $int.Name -ComponentID ms_tcpip6
}
}
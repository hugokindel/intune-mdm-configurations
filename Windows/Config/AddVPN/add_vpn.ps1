$existingConnection = Remove-VpnConnection -Name "VPN" -AllUserConnection -Force

if($?) {
   Add-VpnConnection -Name "VPN" -ServerAddress "Put IP" -TunnelType "L2tp" -L2tpPsk "Put Shared Secret" -AllUserConnection -RememberCredential -Force
}

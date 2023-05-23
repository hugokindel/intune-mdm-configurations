# Intune MDM Configurations

Contains the scripts and configurations related to Intune for all currently supported operating systems (macOS, Windows).  
Disclaimer : Some script have been REDACTED to remove private data. In which case they will not work as is and will need to be modified/adapted.

# macOS

## Scripts (Shell)

- Installer for BitDefender
- Installer for Slack
- Installer for Google Chrome
- Installer for Company Portal (originally from Microsoft)
- Installer for Python (originally from Microsoft)
- Installer for Office (originally from Microsoft)
- Set Outlook as default browser (originally from Microsoft)
- Add administrator account (runs a signed and notarized package installer with a binary used to add the account)
- Disable Microsoft AutoUpdate Required Data Notice screen
- Get battery condition
- Get battery condition (number of cycles)
- Get CPU name
- Get RAM count

## Configurations

- Add VPN configuration (user still needs to associate his username/password)
- Hide "New Background Services" notifications for software added by Intune
- Force authorization of notifications for BitDefender
- Force authorization of notifications for Slack
- Force authorization of notifications for Google Chrome
- Force authorization of notifications for Company Portal
- Force authorization of notifications for Office

# Windows

## Scripts (PowerShell)

- Installer for BitDefender
- Add VPN configuration (user still needs to add DNS settings and associate his username/password)

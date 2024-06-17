Get-AppxPackage Microsoft.ZuneMusic | Remove-AppxPackage
Get-AppxPackage Microsoft.MicrosoftOfficeHub | Remove-AppxPackage
Get-AppxPackage Microsoft.YourPhone | Remove-AppxPackage
Get-AppxPackage Microsoft.Office.OneNote | Remove-AppxPackage
Get-AppxPackage microsoft.windowscommunicationsapps | Remove-AppxPackage
Get-AppxPackage Microsoft.MicrosoftSolitaireCollection | Remove-AppxPackage
Get-AppxPackage Microsoft.SkypeApp | Remove-AppxPackage
Get-AppxPackage *MSTeams* | Remove-AppxPackage

#Removes Creative Cloud
start /w "" "C:\Program Files (x86)\Adobe\Adobe Creative Cloud\Utils\Creative Cloud Uninstaller.exe" -uninstall


function unInstallTeams($path) {
  $clientInstaller = "$($path)\Update.exe"
  
   try {
        $process = Start-Process -FilePath "$clientInstaller" -ArgumentList "--uninstall /s" -PassThru -Wait -ErrorAction STOP
        if ($process.ExitCode -ne 0)
    {
      Write-Error "UnInstallation failed with exit code  $($process.ExitCode)."
        }
    }
    catch {
        Write-Error $_.Exception.Message
    }
}

# Remove Teams for Current Users
$localAppData = "$($env:LOCALAPPDATA)\Microsoft\Teams"
$programData = "$($env:ProgramData)\$($env:USERNAME)\Microsoft\Teams"
If (Test-Path "$($localAppData)\Current\Teams.exe") 
{
  unInstallTeams($localAppData)
    
}
elseif (Test-Path "$($programData)\Current\Teams.exe") {
  unInstallTeams($programData)
}
else {
  Write-Warning  "Teams installation not found"
}

#Installs New Teams
Add-AppProvisionedPackage -Online -PackagePath "C:\FB\Install Media\MSTeams-x64.msix" -SkipLicense

#Installs Adobe Standard
Add-AppProvisionedPackage -Online -PackagePath "C:\FB\Install Media\Adobe Acrobat\Setup.exe" -SkipLicense

#!/bin/zsh

# uninstall adobe cc apps
# loosly based on: https://maclabs.jazzace.ca/2020/11/01/unistalling-adobe-apps.html
# and https://helpx.adobe.com/enterprise/admin-guide.html/enterprise/using/uninstall-creative-cloud-products.ug.html

uninstallDir="/Library/Application Support/Adobe/Uninstall"
setup="/Library/Application Support/Adobe/Adobe Desktop Common/HDBox/Setup"

function removeAdobeApps {

  if [[ -d "${uninstallDir}" ]] && [[ -f "${setup}" ]]; then
    adobeAppList=$(find "${uninstallDir}" -type f -maxdepth 1 -name "*.adbarg")

    for i in ${(f)adobeAppList}; do
      if [[ -f "${i}" ]]; then
        appName=$(echo "${i}" | awk -F "/" '{print $NF}' | cut -d "." -f 1)
        echo "Attempting to uninstall ${appName}"
        sapCode=$(grep -e "^--sapCode=" "${i}" | awk -F "=" '{print $2}')
        echo "sapCode: ${sapCode}"
        prodVer=$(grep -e "^--productVersion=" "${i}" | awk -F "=" '{print $2}')
        echo "prouctVersion: ${prodVer}"
        "${setup}" --uninstall=1 --sapCode="${sapCode}" --productVersion="${prodVer}" --platform=osx10-64 --deleteUserPreferences=false
      fi
    done

  else
    echo "No Adobe apps found to uninstall"
  fi

}

# Start

echo "Start first try..."
removeAdobeApps

echo "Start second try..."
removeAdobeApps

# Uninstall Acrobat DC 15
if [[ -f "/Applications/Adobe Acrobat DC/Adobe Acrobat.app/Contents/Helpers/Acrobat Uninstaller.app/Contents/MacOS/RemoverTool" ]]; then
  echo "Attempting to uninstall Acrobat DC 15"
  "/Applications/Adobe Acrobat DC/Adobe Acrobat.app/Contents/Helpers/Acrobat Uninstaller.app/Contents/MacOS/RemoverTool" "/Applications/Adobe Acrobat DC/Adobe Acrobat.app/Contents/Helpers/Acrobat Uninstaller.app/Contents/MacOS/RemoverTool" "/Applications/Adobe Acrobat DC/Adobe Acrobat.app"
 fi 

# Uninstall Acrobat DC 18+
if [[ -f "/Applications/Adobe Acrobat DC/Adobe Acrobat.app/Contents/Helpers/Acrobat Uninstaller.app/Contents/Library/LaunchServices/com.adobe.Acrobat.RemoverTool" ]]; then
  echo "Attempting to uninstall Acrobat DC"
  "/Applications/Adobe Acrobat DC/Adobe Acrobat.app/Contents/Helpers/Acrobat Uninstaller.app/Contents/Library/LaunchServices/com.adobe.Acrobat.RemoverTool" "/Applications/Adobe Acrobat DC/Adobe Acrobat.app/Contents/Helpers/Acrobat Uninstaller.app/Contents/MacOS/Acrobat Uninstaller" "/Applications/Adobe Acrobat DC/Adobe Acrobat.app"
fi

# Uninstall the Creative Cloud Desktop app
if [[ -f "/Applications/Utilities/Adobe Creative Cloud/Utils/Creative Cloud Uninstaller.app/Contents/MacOS/Creative Cloud Uninstaller" ]]; then
  echo "Attempting to uninstall Creative Cloud Desktop"
  "/Applications/Utilities/Adobe Creative Cloud/Utils/Creative Cloud Uninstaller.app/Contents/MacOS/Creative Cloud Uninstaller" -u
fi

exit 0
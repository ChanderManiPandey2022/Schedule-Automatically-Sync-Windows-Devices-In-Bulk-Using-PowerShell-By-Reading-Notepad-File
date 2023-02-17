<#
.SYNOPSIS
  < Automatically Sync Bulk Devices In Intune Using PowerShell By Reading Device Name from Notepad file >

.DESCRIPTION
  <Automatically Sync Bulk Devices In Intune Using PowerShell By Reading Device Name from Notepad file>

.Demo
<YouTube video link--> https://www.youtube.com/@chandermanipandey8763

.INPUTS
  <Provide all required inforamtion in User Input Section>

.OUTPUTS
  
.NOTES
  Version:         1.0
  Author:          ChanderMani Pandey
  Creation Date:   16 Feb 2023
  Find Author on 
  Youtube:-        https://www.youtube.com/@chandermanipandey8763
  Twitter:-        https://twitter.com/Mani_CMPandey
  Facebook:-       https://www.facebook.com/profile.php?id=100087275409143&mibextid=ZbWKwL
  LinkedIn:-       https://www.linkedin.com/in/chandermanipandey
  Reddit:-         https://www.reddit.com/u/ChanderManiPandey 
 #>

CLS
Set-ExecutionPolicy -ExecutionPolicy 'ByPass' -Scope 'Process' -Force -ErrorAction 'Stop' 

#=====================================User Input Section===============================================================================

$InputDeviceList = Get-Content  "C:\Temp\DevcieList.txt" # "InputDeviceList.txt" Location
$loggingLocation = "C:\Intune_BulkDeviceSync\Sync_Logs" #Log Location
$tenantName = "CMPDempLab.onmicrosoft.com"
$AppId = "150df515-4e24-40df-b6bb-062486e71da9"
$client_Secret ="lAz8Q~7XIlAEV2IbyxYtj14bl1wdnlx8a06H0be0"
#=========================================Microsoft.Graph.Intune Module================================================================

$MGIModule = Get-module -Name "Microsoft.Graph.Intune" -ListAvailable
Write-Host "Checking Microsoft.Graph.Intune is Installed or Not"

    If ($MGIModule -eq $null) 
    {
        Write-Host "Microsoft.Graph.Intune module is not Installed" -ForegroundColor Red
        Write-Host "Installing Microsoft.Graph.Intune module" -ForegroundColor yellow
        Install-Module -Name Microsoft.Graph.Intune -Force 
        Write-Host "Microsoft.Graph.Intune Installed Successfully" -ForegroundColor Green
        Write-Host "Importing Microsoft.Graph.Intune module" -ForegroundColor Yellow
        Write-Host "Microsoft.Graph.Intune Successfully Imported" -ForegroundColor Green
        Import-Module Microsoft.Graph.Intune -Force
    }

    ELSE 
    {   Write-Host "Microsoft.Graph.Intune is Installed" -ForegroundColor Green
        Write-Host "Importing Microsoft.Graph.Intune module" -ForegroundColor green
        Write-Host "                          "  
        Import-Module Microsoft.Graph.Intune -Force
    }
$tenant = $tenantName
$authority = “https://login.windows.net/$tenant”
$clientId= $AppId 
$clientSecret = $client_Secret


Update-MSGraphEnvironment -AppId $clientId -Quiet
Update-MSGraphEnvironment -AuthUrl $authority -Quiet
Connect-MSGraph -ClientSecret $ClientSecret  -Quiet
Update-MSGraphEnvironment -SchemaVersion "Beta" -Quiet

$Devices = Invoke-MSGraphRequest -HttpMethod GET -Url "deviceManagement/managedDevices" | Get-MSGraphAllPages | Select-Object deviceName , id 

# Set the paths to the log files

$Not_SuccessfullSyncDeviceList = Join-Path $loggingLocation "Not_SuccessfullSyncDeviceList.log" #Not_SuccessfullSyncDeviceList
$SuccessfullSyncDeviceList = Join-Path $loggingLocation "SuccessfullSyncDeviceList.log" #SuccessfullSyncDeviceList

# Set the counters for "$DeviceNotFound" and "SuccessfullDeviceSync" value to 0
$DeviceNotFound = 0
$SuccessfullDeviceSync = 0

# Create the logs directory if it doesn't exist
$logDirectory = $loggingLocation
if (-not (Test-Path -Path $logDirectory)) {
  New-Item -ItemType Directory -Path $logDirectory | Out-Null
}

# Create the "Not_SuccessfullSyncDeviceList" log file if it doesn't exist
if (-not (Test-Path -Path $Not_SuccessfullSyncDeviceList)) {
  New-Item -ItemType File -Path $Not_SuccessfullSyncDeviceList | Out-Null
}

# Create the "SuccessfullSyncDeviceList" log file if it doesn't exist
if (-not (Test-Path -Path $SuccessfullSyncDeviceList)) {
  New-Item -ItemType File -Path $SuccessfullSyncDeviceList | Out-Null
}


# Loop through each deviceNamelist and look up the corresponding DeviceID
foreach ($name in $InputDeviceList) {
  $device = $Devices | Where-Object { $_.DeviceName -eq $name }
  if ($device -eq $null) {
    $DeviceNotFound ++
    $message = "$(Get-Date),Device '$name' not found in Intune / Device List."
    Write-Host "Device '$name' not found in Intune / Device List" -ForegroundColor Red  
    Add-Content -Path $Not_SuccessfullSyncDeviceList -Value $message
  }
  else {
    $SuccessfullDeviceSync++
    $id = $device.Id
    $message = "$(Get-Date),DeviceName=$name,DeviceID= $id,SyncStatus=Successful"
    Write-Output "$name : $id"
    Write-Host "Sending Sync request for DeviceName ="$name"" -ForegroundColor Yellow
    Write-Host "Successfully completed the Sync request for ="$name""   -ForegroundColor Green  
    Write-Host "                          "  
    Invoke-IntuneManagedDeviceSyncDevice -managedDeviceId $ID
    Add-Content -Path $SuccessfullSyncDeviceList -Value $message
  }
}

# Output the total number of "SuccessfullDeviceSync" and "DeviceNotFound" Count
Write-Host " "
Write-Host "Total number of Successful Device Sync: $SuccessfullDeviceSync" -ForegroundColor Green
Write-Host "Total number of Device Not Found : $DeviceNotFound " -ForegroundColor Red
Write-Host " "
Write-Host "Log location:$loggingLocation" -ForegroundColor Green

#================================================= Script End==============================================================================================================


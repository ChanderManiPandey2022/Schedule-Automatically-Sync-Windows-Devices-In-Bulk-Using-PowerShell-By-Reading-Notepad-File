<#
.SYNOPSIS
  <Creating Task Schedul using Powershell>

.NOTES
  Version:         1.0
  Author:          ChanderMani Pandey
  Creation Date:   16 Feb 2023
  Find Author on 
  Youtube:-        https://www.youtube.com/@chandermanipandey8763
  Twitter:-        https://twitter.com/Mani_CMPandey
  Facebook:-       https://www.facebook.com/profile.php?id=100087275409143&mibextid=ZbWKwL
  LinkedIn:-       https://www.linkedin.com/in/chandermanipandey
   #>
  
Set-ExecutionPolicy -ExecutionPolicy 'ByPass' -Scope 'Process' -Force -ErrorAction 'Stop' 

$error.clear() ## this is the clear error history 
cls
$ErrorActionPreference = 'SilentlyContinue';
  
 ###########################  User Input Section   ###############################################
    $TaskName = "Sync Bulk Devices In Intune "
    $Description = "Automatically Sync Bulk Devices In Intune Using PowerShell ByReading Device Name from Notepad file"
    $ScriptPath = "C:\temp\Sync_Windows_Devices.ps1"
    $ScheduleTime = "9am"
    
################################################################################################## 
    # Create task scheduled  action
    $action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-NoProfile -ExecutionPolicy bypass -WindowStyle Hidden -File $ScriptPath"

    # Create trigger for scheduled task 
    $timespan = New-Timespan -minutes 5
    $triggers = @()
    $triggers += New-ScheduledTaskTrigger -Daily -At $ScheduleTime
   
    # Register scheduled task
    Register-ScheduledTask -User SYSTEM -Action $action -Trigger $triggers -TaskName "$TaskName" -Description "$Description" -Force
    Write-Host "$TaskName Succesfully created" -ForegroundColor Green

################################# END ############################################################

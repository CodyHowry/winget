Param
  (
    [parameter(Mandatory=$false)]
    [String[]]
    $param
  )
  
$ProgramName = "Notepad++.Notepad++"
$Path_local = "$Env:Programfiles\_MEM"
Start-Transcript -Path "$Path_local\Log\$ProgramName-install.log" -Force -Append

# resolve winget_exe
$winget_exe = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe"
if ($winget_exe.count -gt 1){
        $winget_exe = $winget_exe[-1].Path
}

if (!$winget_exe){Write-Error "Winget not installed"}

& $winget_exe install --exact --id $ProgramName --silent --accept-package-agreements --accept-source-agreements --scope=machine $param


# Update Variables

$PackageName = "winget-Notepad++"
$Version = 1


# Upgrade Script
$upgrade_script_path = "$Path_local\Data\$PackageName\$PackageName.ps1"
$upgrade_script = @("
# resolve and navigate to winget
`$Path_WingetAll = Resolve-Path ""C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe""
if(`$Path_WingetAll){`$Path_Winget = `$Path_WingetAll[-1].Path}
cd `$Path_Winget

.\winget.exe upgrade Notepad++.Notepad++ --silent --force --accept-package-agreements --accept-source-agreements 

")
$upgrade_script | Out-File $(New-Item $upgrade_script_path -Type File -Force)

# Scheduled Task for "winget upgrades"
$schtaskName = "Notepad++ - UPDATER"
$schtaskDescription = "Manages the Updates of Notepad++. V$($Version)"
$trigger1 = New-ScheduledTaskTrigger -AtStartup
$trigger2 = New-ScheduledTaskTrigger -Weekly -WeeksInterval 1 -DaysOfWeek Wednesday -At 8pm
$principal= New-ScheduledTaskPrincipal -UserId 'SYSTEM'
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument '-ExecutionPolicy Bypass -File "C:\Program Files\_MEM\Data\winget-Notepad++\winget-Notepad++.ps1"'
$settings= New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

Register-ScheduledTask -TaskName $schtaskName -Trigger $trigger1,$trigger2 -Action $action -Principal $principal -Settings $settings -Description $schtaskDescription -Force


Stop-Transcript


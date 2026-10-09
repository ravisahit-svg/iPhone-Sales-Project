param([Parameter(Mandatory=$true)][string]$Number,[Parameter(Mandatory=$true)][string]$SqlFile)
$ErrorActionPreference='Stop'
$projectRoot=Split-Path -Parent $MyInvocation.MyCommand.Path
$evidenceTitle="Ravi iPhone Project | $([int]$Number)"
$Host.UI.RawUI.WindowTitle=$evidenceTitle
$Host.UI.RawUI.BackgroundColor='Black'
$Host.UI.RawUI.ForegroundColor='White'
Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class RaviConsoleFont {
 [StructLayout(LayoutKind.Sequential)] public struct Coord {public short X; public short Y;}
 [StructLayout(LayoutKind.Sequential,CharSet=CharSet.Unicode)] public struct FontInfo {public uint cbSize;public uint nFont;public Coord dwFontSize;public uint FontFamily;public uint FontWeight;[MarshalAs(UnmanagedType.ByValTStr,SizeConst=32)]public string FaceName;}
 [DllImport("kernel32.dll")]public static extern IntPtr GetStdHandle(int n);
 [DllImport("kernel32.dll",CharSet=CharSet.Unicode)]public static extern bool SetCurrentConsoleFontEx(IntPtr h,bool max,ref FontInfo f);
 public static void Set(){var f=new FontInfo();f.cbSize=(uint)Marshal.SizeOf(f);f.dwFontSize.Y=12;f.FaceName="Consolas";f.FontWeight=400;SetCurrentConsoleFontEx(GetStdHandle(-11),false,ref f);}
}
'@
[RaviConsoleFont]::Set()
$maxSize=$Host.UI.RawUI.MaxPhysicalWindowSize
$cols=[Math]::Min(240,$maxSize.Width)
$rows=[Math]::Min(68,$maxSize.Height-2)
$Host.UI.RawUI.BufferSize=New-Object Management.Automation.Host.Size($cols,4000)
$Host.UI.RawUI.WindowSize=New-Object Management.Automation.Host.Size($cols,$rows)
Clear-Host
$logPath=Join-Path $projectRoot "logs\actual-evidence-$Number.log"
Start-Transcript -Path $logPath -Force | Out-Null
Write-Host 'Ravi iPhone Sales Analytics Project'
Write-Host 'Actual Docker project account:'
docker exec -u takeo takeo-de-env whoami
Write-Host 'Actual container: takeo-de-env'
Write-Host ''
Write-Host 'Executing these commands:'
if($Number -eq '04') {
    Write-Host 'hadoop fs -cat /iphone/project-info.txt; hadoop fs -ls /warehouse/tablespace/managed/hive/'
    docker exec -u takeo takeo-de-env bash -lc 'source /home/takeo/ravi-iphone-project/env.sh; hadoop fs -cat /iphone/project-info.txt; hadoop fs -ls /warehouse/tablespace/managed/hive/'
} else {
    Get-Content -LiteralPath (Join-Path $projectRoot $SqlFile) | ForEach-Object {Write-Host $_}
    $containerSql='/home/takeo/ravi-iphone-project/'+($SqlFile.Replace('\','/'))
    $nativeCommand="source /home/takeo/ravi-iphone-project/env.sh; beeline -u jdbc:hive2://localhost:10004/ -n takeo --silent=true --showHeader=true --outputformat=table --maxWidth=240 --maxColumnWidth=95 -f $containerSql 2> /home/takeo/ravi-iphone-project/logs/client-$Number.stderr"
    docker exec -u takeo takeo-de-env bash -lc $nativeCommand
}
$evidenceExit=$LASTEXITCODE
Stop-Transcript | Out-Null
$finishedRows=[Math]::Min($rows,[Math]::Max(12,$Host.UI.RawUI.CursorPosition.Y+5))
$Host.UI.RawUI.WindowSize=New-Object Management.Automation.Host.Size($cols,$finishedRows)
$Host.UI.RawUI.WindowPosition=New-Object Management.Automation.Host.Coordinates(0,0)
@{number=$Number;pid=$PID;title=$evidenceTitle;exitCode=$evidenceExit} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $projectRoot "logs\actual-evidence-$Number-ready.json")
if($evidenceExit -ne 0){Write-Host "Execution failed: $evidenceExit" -ForegroundColor Red}

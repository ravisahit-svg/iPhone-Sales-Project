param([Parameter(Mandatory=$true)][string]$TitleContains,[Parameter(Mandatory=$true)][string]$OutputPath)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
Add-Type @'
using System;
using System.Text;
using System.Collections.Generic;
using System.Runtime.InteropServices;
public static class ProjectWindowCapture {
 public delegate bool Callback(IntPtr h,IntPtr l);
 [DllImport("user32.dll")] public static extern bool EnumWindows(Callback c,IntPtr l);
 [DllImport("user32.dll",CharSet=CharSet.Unicode)] public static extern int GetWindowText(IntPtr h,StringBuilder s,int n);
 [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
 [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h,out Rect r);
 [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr h,IntPtr dc,uint flags);
 [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
 public struct Rect { public int Left,Top,Right,Bottom; }
 public static IntPtr[] Find(string title) {
  var found=new List<IntPtr>();
  EnumWindows((h,l)=>{var s=new StringBuilder(1024);GetWindowText(h,s,1024);if(IsWindowVisible(h)&&s.ToString().Contains(title))found.Add(h);return true;},IntPtr.Zero);
  return found.ToArray();
 }
}
'@
[ProjectWindowCapture]::SetProcessDPIAware() | Out-Null
$windows=[ProjectWindowCapture]::Find($TitleContains)
if($windows.Count -ne 1){throw "Expected one actual project console window, found $($windows.Count)"}
$rect=New-Object ProjectWindowCapture+Rect
if(-not [ProjectWindowCapture]::GetWindowRect($windows[0],[ref]$rect)){throw 'Window bounds unavailable'}
$bitmap=New-Object Drawing.Bitmap(($rect.Right-$rect.Left),($rect.Bottom-$rect.Top))
$graphics=[Drawing.Graphics]::FromImage($bitmap)
$dc=$graphics.GetHdc()
try {if(-not [ProjectWindowCapture]::PrintWindow($windows[0],$dc,2)){throw 'Actual window capture failed'}}
finally {$graphics.ReleaseHdc($dc);$graphics.Dispose()}
$bitmap.Save($OutputPath,[Drawing.Imaging.ImageFormat]::Png)
$bitmap.Dispose()
Write-Output "Saved direct console capture: $OutputPath"

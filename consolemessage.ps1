# --- Helper to display console message         ---
# --- Message should be relative in message.txt ---
# --- Relaunch in legacy console if needed      ---
$hostName = $Host.Name
if ($hostName -notlike "*ConsoleHost*") {
    Write-Host "Relaunching in legacy console for true fullscreen..."
    $self = $MyInvocation.MyCommand.Definition
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$self`""
    exit
}

# --- Force fullscreen using Win32 API (Alt+Enter programmatically) ---
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class FullScreen {
    [DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")] public static extern bool PostMessage(IntPtr hWnd, uint Msg, int wParam, int lParam);
}
"@

$hwnd = [FullScreen]::GetConsoleWindow()
# 0x112 = WM_SYSCOMMAND, 0xF030 = SC_MAXIMIZE, 0xF120 = SC_FULLSCREEN (Alt+Enter)
[FullScreen]::PostMessage($hwnd, 0x112, 0xF120, 0)

Start-Sleep -Milliseconds 200

# --- Maximize buffer + window ---
$host.UI.RawUI.WindowTitle = "ASCII Message"
$maxWidth  = $host.UI.RawUI.MaxPhysicalWindowSize.Width
$maxHeight = $host.UI.RawUI.MaxPhysicalWindowSize.Height

$host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size ($maxWidth, $maxHeight)
$host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size ($maxWidth, $maxHeight)

# --- UTF-8 output ---
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# --- Path to your ASCII file ---
$filePath = ".\message.txt"

# --- Print each line with delay ---
if (Test-Path $filePath) {
    Get-Content $filePath -Encoding UTF8 | ForEach-Object {
        Write-Host $_
        Start-Sleep -Milliseconds 100
    }
} else {
    Write-Host "File not found: $filePath"
}

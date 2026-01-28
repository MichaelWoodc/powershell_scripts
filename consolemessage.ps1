# ============================
#  One-time relaunch in plain console
# ============================

if (-not $env:CONSOLEMESSAGE_NATIVE) {
    # Mark that we've relaunched so the child doesn't loop
    $env:CONSOLEMESSAGE_NATIVE = "1"

    $self = $MyInvocation.MyCommand.Definition

    # Launch a plain powershell.exe console window, maximized
    Start-Process powershell.exe `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$self`"" `
        -WindowStyle Maximized

    exit
}

# ============================
#  Now we're in the "plain jane" console
#  Make it as big as possible
# ============================

$raw = $Host.UI.RawUI
$raw.WindowTitle = "ASCII Message"

$maxWidth  = $raw.MaxPhysicalWindowSize.Width
$maxHeight = $raw.MaxPhysicalWindowSize.Height

# Buffer must be >= window size
$raw.BufferSize = New-Object System.Management.Automation.Host.Size ($maxWidth, $maxHeight)
$raw.WindowSize = New-Object System.Management.Automation.Host.Size ($maxWidth, $maxHeight)

# ============================
#  UTF-8 output
# ============================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ============================
#  ASCII file path
# ============================

$filePath = ".\message.txt"

# ============================
#  Print each line with delay
#  (simple version; we can re-add blank-line collapsing if you want)
# ============================

if (Test-Path $filePath) {
    Get-Content $filePath -Encoding UTF8 | ForEach-Object {
        Write-Host $_
        Start-Sleep -Milliseconds 100
    }
} else {
    Write-Host "File not found: $filePath"
}

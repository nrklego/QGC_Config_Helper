param (
    [Parameter(Mandatory = $true)]
    [string]$SourceFile,

    [Parameter(Mandatory = $true)]
    [string]$DestinationFolder,

    [string]$IconPath = "",

    [switch]$RunAsAdmin
)

# Ensure the destination folder exists
if (!(Test-Path $DestinationFolder)) {
    New-Item -ItemType Directory -Path $DestinationFolder | Out-Null
}

# Build shortcut path
$shortcutName = [System.IO.Path]::GetFileNameWithoutExtension($SourceFile) + ".lnk"
$shortcutPath = Join-Path $DestinationFolder $shortcutName

try {
    $resolvedSource = (Resolve-Path $SourceFile).Path
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $resolvedSource
    $shortcut.WorkingDirectory = (Split-Path -Parent $resolvedSource)

    # Set custom icon if provided
    if ($IconPath -and (Test-Path $IconPath)) {
        $shortcut.IconLocation = (Resolve-Path $IconPath).Path
    } else {
        $shortcut.IconLocation = "C:\Windows\System32\shell32.dll,41"
    }

    $shortcut.Save()

    # Optional: Enable "Run as administrator"
    if ($RunAsAdmin) {
        $bytes = [System.IO.File]::ReadAllBytes($shortcutPath)

        # Set the 21st byte (bit 0x20) in the .lnk file to enable "RunAsAdmin"
        # This is a known undocumented flag used by Windows shortcuts
        $bytes[21] = $bytes[21] -bor 0x20

        [System.IO.File]::WriteAllBytes($shortcutPath, $bytes)
        Write-Host "'Run as administrator' enabled for shortcut."
    }

    Write-Host "Shortcut created: $shortcutPath" -ForegroundColor Green
} catch {
    Write-Host "Failed to create shortcut: $_" -ForegroundColor Red
    exit 1
}

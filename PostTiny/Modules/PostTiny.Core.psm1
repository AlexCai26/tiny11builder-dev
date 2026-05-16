Set-StrictMode -Version Latest

function Assert-PostTinyAdministrator {
    $currentIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($currentIdentity)
    $isAdmin = $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)

    if (-not $isAdmin) {
        throw 'PostTiny requires administrator privileges. Please rerun PowerShell as Administrator.'
    }
}

function Ensure-PostTinyDirectory {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Write-PostTinyBanner {
    param (
        [Parameter(Mandatory = $true)]
        [string]$PresetName
    )

    Write-Host '============================================================================' -ForegroundColor Cyan
    Write-Host '  PostTiny - Online Windows Post-Install Customizer' -ForegroundColor Cyan
    Write-Host "  Preset: $PresetName" -ForegroundColor Cyan
    Write-Host '============================================================================' -ForegroundColor Cyan
    Write-Host ''
}

function Write-PostTinySection {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Title
    )

    Write-Host ''
    Write-Host "[$Title]" -ForegroundColor Yellow
}

function Start-PostTinyTranscriptLogging {
    param (
        [Parameter(Mandatory = $true)]
        [string]$BasePath
    )

    $logsPath = Join-Path $BasePath 'Logs'
    Ensure-PostTinyDirectory -Path $logsPath

    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $script:PostTinyTranscriptPath = Join-Path $logsPath "PostTiny-$timestamp.log"
    Start-Transcript -Path $script:PostTinyTranscriptPath | Out-Null
    $script:PostTinyTranscriptStarted = $true

    return $script:PostTinyTranscriptPath
}

function Stop-PostTinyTranscriptLogging {
    if ($script:PostTinyTranscriptStarted) {
        try {
            Stop-Transcript | Out-Null
        }
        catch {
        }
        $script:PostTinyTranscriptStarted = $false
    }
}

function Convert-PostTinyRegistryPathToNative {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $nativePath = $Path `
        -replace '^Registry::HKEY_LOCAL_MACHINE\\', 'HKLM\' `
        -replace '^Registry::HKEY_CURRENT_USER\\', 'HKCU\' `
        -replace '^Registry::HKEY_CLASSES_ROOT\\', 'HKCR\' `
        -replace '^Registry::HKEY_USERS\\', 'HKU\' `
        -replace '^Registry::HKEY_CURRENT_CONFIG\\', 'HKCC\' `
        -replace '^HKLM:\\', 'HKLM\' `
        -replace '^HKCU:\\', 'HKCU\' `
        -replace '^HKCR:\\', 'HKCR\' `
        -replace '^HKU:\\', 'HKU\' `
        -replace '^HKCC:\\', 'HKCC\'

    return $nativePath
}

function Convert-PostTinyHexStringToBytes {
    param (
        [Parameter(Mandatory = $true)]
        [string]$HexString
    )

    $normalized = ($HexString -replace '[^0-9A-Fa-f]', '')
    if ($normalized.Length % 2 -ne 0) {
        throw "Invalid hex string length: $HexString"
    }

    $bytes = New-Object byte[] ($normalized.Length / 2)
    for ($index = 0; $index -lt $normalized.Length; $index += 2) {
        $bytes[$index / 2] = [Convert]::ToByte($normalized.Substring($index, 2), 16)
    }

    return $bytes
}

function Set-PostTinyRegistryValue {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Name,

        [AllowNull()]
        [object]$Value,

        [ValidateSet('String', 'ExpandString', 'MultiString', 'Binary', 'DWord', 'QWord')]
        [string]$Type = 'String'
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }

    $propertyValue = $Value
    if ($Type -eq 'Binary' -and $Value -is [string]) {
        $propertyValue = Convert-PostTinyHexStringToBytes -HexString $Value
    }

    if ($Type -eq 'MultiString' -and $Value -isnot [System.Array]) {
        $propertyValue = @($Value)
    }

    New-ItemProperty -Path $Path -Name $Name -PropertyType $Type -Value $propertyValue -Force | Out-Null
}

function Set-PostTinyRegistryDefaultValue {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [AllowNull()]
        [string]$Value = '',

        [ValidateSet('REG_SZ', 'REG_EXPAND_SZ', 'REG_DWORD')]
        [string]$Type = 'REG_SZ'
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }

    $nativePath = Convert-PostTinyRegistryPathToNative -Path $Path
    & reg.exe add $nativePath /ve /t $Type /d $Value /f | Out-Null
}

function Remove-PostTinyRegistryKey {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (Test-Path -LiteralPath $Path) {
        Remove-Item -Path $Path -Recurse -Force
    }
}

function Set-PostTinyServiceStartup {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ServiceName,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Automatic', 'Manual', 'Disabled')]
        [string]$StartupType,

        [switch]$StopService
    )

    $serviceRegPath = "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\$ServiceName"
    $startupMap = @{
        Automatic = 2
        Manual    = 3
        Disabled  = 4
    }

    if (-not (Test-Path -LiteralPath $serviceRegPath)) {
        Write-Warning "Service '$ServiceName' was not found."
        return
    }

    Set-PostTinyRegistryValue -Path $serviceRegPath -Name 'Start' -Value $startupMap[$StartupType] -Type DWord

    try {
        Set-Service -Name $ServiceName -StartupType $StartupType -ErrorAction Stop
    }
    catch {
    }

    if ($StopService) {
        try {
            Stop-Service -Name $ServiceName -Force -ErrorAction Stop
        }
        catch {
        }
    }
}

function Remove-PostTinyPath {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        return $false
    }

    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    $isDirectory = (Get-Item -LiteralPath $Path).PSIsContainer

    if ($isDirectory) {
        & takeown.exe /F $Path /R /D Y | Out-Null
        & icacls.exe $Path /grant "${currentUser}:(F)" /T /C | Out-Null
        Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction SilentlyContinue
    }
    else {
        & takeown.exe /F $Path | Out-Null
        & icacls.exe $Path /grant "${currentUser}:(F)" /C | Out-Null
        Remove-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    }

    return (-not (Test-Path -LiteralPath $Path))
}

Export-ModuleMember -Function @(
    'Assert-PostTinyAdministrator',
    'Ensure-PostTinyDirectory',
    'Write-PostTinyBanner',
    'Write-PostTinySection',
    'Start-PostTinyTranscriptLogging',
    'Stop-PostTinyTranscriptLogging',
    'Convert-PostTinyRegistryPathToNative',
    'Set-PostTinyRegistryValue',
    'Set-PostTinyRegistryDefaultValue',
    'Remove-PostTinyRegistryKey',
    'Set-PostTinyServiceStartup',
    'Remove-PostTinyPath'
)

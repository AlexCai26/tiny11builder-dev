Set-StrictMode -Version Latest

Import-Module (Join-Path $PSScriptRoot 'PostTiny.Core.psm1') -Force -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot 'PostTiny.Appx.psm1') -Force -DisableNameChecking

function Invoke-PostTinyVisualEffects {
    Write-PostTinySection -Title 'Visual Effects'

    $desktopPath = 'Registry::HKEY_CURRENT_USER\Control Panel\Desktop'
    $advancedPath = 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    $dwmPath = 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\DWM'
    $visualEffectsPath = 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects'
    $windowMetricsPath = 'Registry::HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics'

    Set-PostTinyRegistryValue -Path $visualEffectsPath -Name 'VisualFXSetting' -Value 3 -Type DWord
    Set-PostTinyRegistryValue -Path $desktopPath -Name 'UserPreferencesMask' -Value '9032018010000000' -Type Binary
    Set-PostTinyRegistryValue -Path $desktopPath -Name 'FontSmoothing' -Value '2' -Type String
    Set-PostTinyRegistryValue -Path $desktopPath -Name 'FontSmoothingType' -Value 2 -Type DWord
    Set-PostTinyRegistryValue -Path $desktopPath -Name 'DragFullWindows' -Value '0' -Type String
    Set-PostTinyRegistryValue -Path $windowMetricsPath -Name 'MinAnimate' -Value '0' -Type String

    Set-PostTinyRegistryValue -Path $advancedPath -Name 'ListviewShadow' -Value 0 -Type DWord
    Set-PostTinyRegistryValue -Path $advancedPath -Name 'ListviewAlphaSelect' -Value 0 -Type DWord
    Set-PostTinyRegistryValue -Path $advancedPath -Name 'TaskbarAnimations' -Value 0 -Type DWord
    Set-PostTinyRegistryValue -Path $advancedPath -Name 'IconsOnly' -Value 1 -Type DWord

    Set-PostTinyRegistryValue -Path $dwmPath -Name 'EnableAeroPeek' -Value 0 -Type DWord
    Set-PostTinyRegistryValue -Path $dwmPath -Name 'AlwaysHibernateThumbnails' -Value 0 -Type DWord
    Set-PostTinyRegistryValue -Path $dwmPath -Name 'ColorPrevalence' -Value 1 -Type DWord
    Set-PostTinyRegistryValue -Path $dwmPath -Name 'Composition' -Value 1 -Type DWord

    $effectValues = @{
        AnimateMinMax         = 0
        ComboBoxAnimation     = 0
        ControlAnimations     = 0
        CursorShadow          = 1
        DragFullWindows       = 0
        DropShadow            = 1
        DWMAeroPeekEnabled    = 0
        DWMEnabled            = 1
        DWMSaveThumbnailEnabled = 0
        FontSmoothing         = 1
        ListBoxSmoothScrolling = 0
        ListviewAlphaSelect   = 0
        ListviewShadow        = 0
        MenuAnimation         = 0
        SelectionFade         = 0
        TaskbarAnimations     = 0
        ThumbnailsOrIcon      = 0
        TooltipAnimation      = 0
    }

    foreach ($entry in $effectValues.GetEnumerator()) {
        Set-PostTinyRegistryValue -Path (Join-Path $visualEffectsPath $entry.Key) -Name 'DefaultApplied' -Value $entry.Value -Type DWord
    }
}

function Invoke-PostTinyFileExplorerDeveloper {
    Write-PostTinySection -Title 'File Explorer'

    $explorerAdvanced = 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    $explorerPath = 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer'
    $searchPath = 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search'
    $policySearchPath = 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search'
    $allFoldersShell = 'Registry::HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell'
    $bag1Shell = 'Registry::HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\1\Shell'
    $bag1ComDlg = 'Registry::HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\1\ComDlg'

    Set-PostTinyRegistryValue -Path $explorerAdvanced -Name 'FolderContentsInfoTip' -Value 1 -Type DWord
    Set-PostTinyRegistryValue -Path $explorerAdvanced -Name 'ShowInfoTip' -Value 1 -Type DWord
    Set-PostTinyRegistryValue -Path $explorerAdvanced -Name 'GroupView' -Value 0 -Type DWord
    Set-PostTinyRegistryValue -Path $explorerAdvanced -Name 'Hidden' -Value 1 -Type DWord
    Set-PostTinyRegistryValue -Path $explorerAdvanced -Name 'HideFileExt' -Value 0 -Type DWord
    Set-PostTinyRegistryValue -Path $explorerAdvanced -Name 'ShowSuperHidden' -Value 0 -Type DWord
    Set-PostTinyRegistryValue -Path $explorerAdvanced -Name 'ShowSecondsInSystemClock' -Value 1 -Type DWord
    Set-PostTinyRegistryValue -Path $explorerAdvanced -Name 'TaskbarAl' -Value 0 -Type DWord
    Set-PostTinyRegistryValue -Path $explorerAdvanced -Name 'TaskbarGlomLevel' -Value 1 -Type DWord
    Set-PostTinyRegistryValue -Path $searchPath -Name 'SearchboxTaskbarMode' -Value 0 -Type DWord
    Set-PostTinyRegistryValue -Path $policySearchPath -Name 'SearchboxTaskbarMode' -Value 0 -Type DWord
    Set-PostTinyRegistryValue -Path $explorerPath -Name 'FolderContentsInfoTip' -Value 1 -Type DWord

    Set-PostTinyRegistryDefaultValue -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\Shell\BagMRU Size' -Value '10230' -Type REG_DWORD

    $commonBagValues = @{
        FolderType      = @{ Value = 'NotSpecified'; Type = 'String' }
        LogicalViewMode = @{ Value = 1; Type = 'DWord' }
        Mode            = @{ Value = 4; Type = 'DWord' }
    }

    foreach ($entry in $commonBagValues.GetEnumerator()) {
        Set-PostTinyRegistryValue -Path $allFoldersShell -Name $entry.Key -Value $entry.Value.Value -Type $entry.Value.Type
        Set-PostTinyRegistryValue -Path $bag1Shell -Name $entry.Key -Value $entry.Value.Value -Type $entry.Value.Type
    }

    Set-PostTinyRegistryValue -Path $allFoldersShell -Name 'IconSize' -Value 16 -Type DWord
    Set-PostTinyRegistryValue -Path $allFoldersShell -Name 'GroupBy' -Value 'System.Null' -Type String
    Set-PostTinyRegistryValue -Path $allFoldersShell -Name 'GroupByDirection' -Value 1 -Type DWord
    Set-PostTinyRegistryValue -Path $allFoldersShell -Name 'GroupByKey:FMTID' -Value '{00000000-0000-0000-0000-000000000000}' -Type String
    Set-PostTinyRegistryValue -Path $allFoldersShell -Name 'GroupByKey:PID' -Value 0 -Type DWord
    Set-PostTinyRegistryValue -Path $allFoldersShell -Name 'Sort' -Value '0000000000000000000000000000000001000000000000000000000000000000010000004e0061006d0065000000' -Type Binary
    Set-PostTinyRegistryValue -Path $bag1Shell -Name 'GroupBy' -Value 'System.Null' -Type String
    Set-PostTinyRegistryValue -Path $bag1ComDlg -Name 'LogicalViewMode' -Value 1 -Type DWord
    Set-PostTinyRegistryValue -Path $bag1ComDlg -Name 'Mode' -Value 4 -Type DWord
}

function Invoke-PostTinyDisableSponsoredApps {
    Write-PostTinySection -Title 'Sponsored Apps'

    $contentDelivery = 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
    $cloudContent = 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\CloudContent'
    $pushToInstall = 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\PushToInstall'
    $mrtPolicy = 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\MRT'
    $startPolicy = 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\current\device\Start'

    $contentValues = @{
        OemPreInstalledAppsEnabled     = 0
        PreInstalledAppsEnabled        = 0
        SilentInstalledAppsEnabled     = 0
        ContentDeliveryAllowed         = 0
        FeatureManagementEnabled       = 0
        PreInstalledAppsEverEnabled    = 0
        SoftLandingEnabled             = 0
        SubscribedContentEnabled       = 0
        'SubscribedContent-310093Enabled' = 0
        'SubscribedContent-338388Enabled' = 0
        'SubscribedContent-338389Enabled' = 0
        'SubscribedContent-338393Enabled' = 0
        'SubscribedContent-353694Enabled' = 0
        'SubscribedContent-353696Enabled' = 0
        SystemPaneSuggestionsEnabled   = 0
    }

    foreach ($entry in $contentValues.GetEnumerator()) {
        Set-PostTinyRegistryValue -Path $contentDelivery -Name $entry.Key -Value $entry.Value -Type DWord
    }

    Set-PostTinyRegistryValue -Path $cloudContent -Name 'DisableWindowsConsumerFeatures' -Value 1 -Type DWord
    Set-PostTinyRegistryValue -Path $cloudContent -Name 'DisableConsumerAccountStateContent' -Value 1 -Type DWord
    Set-PostTinyRegistryValue -Path $cloudContent -Name 'DisableCloudOptimizedContent' -Value 1 -Type DWord
    Set-PostTinyRegistryValue -Path $pushToInstall -Name 'DisablePushToInstall' -Value 1 -Type DWord
    Set-PostTinyRegistryValue -Path $mrtPolicy -Name 'DontOfferThroughWUAU' -Value 1 -Type DWord
    Set-PostTinyRegistryValue -Path $startPolicy -Name 'ConfigureStartPins' -Value '{"pinnedList": [{}]}' -Type String
    Remove-PostTinyRegistryKey -Path (Join-Path $contentDelivery 'Subscriptions')
    Remove-PostTinyRegistryKey -Path (Join-Path $contentDelivery 'SuggestedApps')
}

function Invoke-PostTinyDisableOneDriveBackup {
    Write-PostTinySection -Title 'OneDrive Backup'
    Set-PostTinyRegistryValue -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\OneDrive' -Name 'DisableFileSyncNGSC' -Value 1 -Type DWord
}

function Invoke-PostTinyDisableTelemetry {
    Write-PostTinySection -Title 'Telemetry'

    Set-PostTinyRegistryValue -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' -Name 'Enabled' -Value 0 -Type DWord
    Set-PostTinyRegistryValue -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Privacy' -Name 'TailoredExperiencesWithDiagnosticDataEnabled' -Value 0 -Type DWord
    Set-PostTinyRegistryValue -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy' -Name 'HasAccepted' -Value 0 -Type DWord
    Set-PostTinyRegistryValue -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Input\TIPC' -Name 'Enabled' -Value 0 -Type DWord
    Set-PostTinyRegistryValue -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\InputPersonalization' -Name 'RestrictImplicitInkCollection' -Value 1 -Type DWord
    Set-PostTinyRegistryValue -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\InputPersonalization' -Name 'RestrictImplicitTextCollection' -Value 1 -Type DWord
    Set-PostTinyRegistryValue -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\InputPersonalization\TrainedDataStore' -Name 'HarvestContacts' -Value 0 -Type DWord
    Set-PostTinyRegistryValue -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Personalization\Settings' -Name 'AcceptedPrivacyPolicy' -Value 0 -Type DWord
    Set-PostTinyRegistryValue -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DataCollection' -Name 'AllowTelemetry' -Value 0 -Type DWord
    Set-PostTinyServiceStartup -ServiceName 'dmwappushservice' -StartupType Disabled -StopService
    Set-PostTinyRegistryValue -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Orchestrator\UScheduler\OutlookUpdate' -Name 'workCompleted' -Value 1 -Type DWord
    Set-PostTinyRegistryValue -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Orchestrator\UScheduler\DevHomeUpdate' -Name 'workCompleted' -Value 1 -Type DWord
    Remove-PostTinyRegistryKey -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\OutlookUpdate'
    Remove-PostTinyRegistryKey -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\DevHomeUpdate'
    Set-PostTinyRegistryValue -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot' -Name 'TurnOffWindowsCopilot' -Value 1 -Type DWord
    Set-PostTinyRegistryValue -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Explorer' -Name 'DisableSearchBoxSuggestions' -Value 1 -Type DWord
    Set-PostTinyRegistryValue -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Teams' -Name 'DisableInstallation' -Value 1 -Type DWord
    Set-PostTinyRegistryValue -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Mail' -Name 'PreventRun' -Value 1 -Type DWord
}

function Invoke-PostTinyDisableWidgets {
    Write-PostTinySection -Title 'Widgets'

    Set-PostTinyRegistryValue -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Dsh' -Name 'AllowNewsAndInterests' -Value 0 -Type DWord
    Set-PostTinyRegistryValue -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\NewsAndInterests\AllowNewsAndInterests' -Name 'value' -Value 0 -Type DWord
    Set-PostTinyRegistryValue -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarDa' -Value 0 -Type DWord
}

function Invoke-PostTinyDisableSearchHighlights {
    Write-PostTinySection -Title 'Search Highlights'

    Set-PostTinyRegistryValue -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search' -Name 'EnableDynamicContentInWSB' -Value 0 -Type DWord
    Set-PostTinyRegistryValue -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SearchSettings' -Name 'IsDynamicSearchBoxEnabled' -Value 0 -Type DWord
    Set-PostTinyRegistryValue -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Feeds\DSB' -Name 'ShowDynamicContent' -Value 0 -Type DWord
}

function Invoke-PostTinyDisableXboxServices {
    Write-PostTinySection -Title 'Xbox Services'

    foreach ($service in @('XblAuthManager', 'XblGameSave', 'XboxGipSvc', 'XboxNetApiSvc')) {
        Set-PostTinyServiceStartup -ServiceName $service -StartupType Disabled -StopService
    }
}

function Invoke-PostTinyDisableExtraServices {
    Write-PostTinySection -Title 'Extra Services'

    foreach ($service in @('DiagTrack', 'DoSvc', 'SysMain', 'Fax', 'RemoteRegistry', 'lfsvc', 'RetailDemo', 'DPS', 'WdiServiceHost', 'WdiSystemHost')) {
        Set-PostTinyServiceStartup -ServiceName $service -StartupType Disabled -StopService
    }
}

function Invoke-PostTinySetWindowsSearchManual {
    Write-PostTinySection -Title 'Windows Search'

    Set-PostTinyServiceStartup -ServiceName 'WSearch' -StartupType Manual
    Set-PostTinyRegistryValue -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search' -Name 'AllowCortana' -Value 0 -Type DWord
    Set-PostTinyRegistryValue -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search' -Name 'DisableWebSearch' -Value 1 -Type DWord
}

function Invoke-PostTinyDisableLockScreenSpotlight {
    Write-PostTinySection -Title 'Lock Screen'

    $contentDelivery = 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
    $cloudContent = 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\CloudContent'
    $systemPolicy = 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System'

    Set-PostTinyRegistryValue -Path $contentDelivery -Name 'RotatingLockScreenEnabled' -Value 0 -Type DWord
    Set-PostTinyRegistryValue -Path $contentDelivery -Name 'RotatingLockScreenOverlayEnabled' -Value 0 -Type DWord
    Set-PostTinyRegistryValue -Path $contentDelivery -Name 'SubscribedContent-338387Enabled' -Value 0 -Type DWord
    Set-PostTinyRegistryValue -Path $contentDelivery -Name 'SubscribedContent-338389Enabled' -Value 0 -Type DWord
    Set-PostTinyRegistryValue -Path $cloudContent -Name 'DisableWindowsSpotlightFeatures' -Value 1 -Type DWord
    Set-PostTinyRegistryValue -Path $cloudContent -Name 'DisableSoftLanding' -Value 1 -Type DWord
    Set-PostTinyRegistryValue -Path $cloudContent -Name 'DisableWindowsSpotlightOnActionCenter' -Value 1 -Type DWord
    Set-PostTinyRegistryValue -Path $cloudContent -Name 'DisableWindowsSpotlightWindowsWelcomeExperience' -Value 1 -Type DWord
    Set-PostTinyRegistryValue -Path $systemPolicy -Name 'DisableLockScreenAppNotifications' -Value 1 -Type DWord
    Set-PostTinyRegistryValue -Path 'Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Lock Screen' -Name 'SlideshowEnabled' -Value 0 -Type DWord
}

function Invoke-PostTinyOptimizeEdge {
    Write-PostTinySection -Title 'Edge'

    $edgePolicy = 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge'
    Set-PostTinyRegistryValue -Path $edgePolicy -Name 'NewTabPageContentEnabled' -Value 0 -Type DWord
    Set-PostTinyRegistryValue -Path $edgePolicy -Name 'NewTabPageQuickLinksEnabled' -Value 0 -Type DWord
    Set-PostTinyRegistryValue -Path $edgePolicy -Name 'NewTabPageHideDefaultTopSites' -Value 1 -Type DWord
    Set-PostTinyRegistryValue -Path $edgePolicy -Name 'HubsSidebarEnabled' -Value 0 -Type DWord
    Set-PostTinyRegistryValue -Path $edgePolicy -Name 'HideFirstRunExperience' -Value 1 -Type DWord
    Set-PostTinyRegistryValue -Path $edgePolicy -Name 'EdgeCollectionsEnabled' -Value 0 -Type DWord
    Set-PostTinyRegistryValue -Path $edgePolicy -Name 'EdgeShoppingAssistantEnabled' -Value 0 -Type DWord
    Set-PostTinyRegistryValue -Path $edgePolicy -Name 'EdgeFollowEnabled' -Value 0 -Type DWord
    Set-PostTinyRegistryValue -Path $edgePolicy -Name 'NewTabPageLocation' -Value 'about:blank' -Type String
}

function Invoke-PostTinyEnableTraditionalContextMenu {
    Write-PostTinySection -Title 'Traditional Context Menu'

    $basePath = 'Registry::HKEY_CURRENT_USER\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}'
    $inprocPath = Join-Path $basePath 'InprocServer32'
    Set-PostTinyRegistryDefaultValue -Path $inprocPath -Value ''
}

function Set-PostTinyContextMenuCommand {
    param (
        [Parameter(Mandatory = $true)]
        [string]$BasePath,

        [Parameter(Mandatory = $true)]
        [string]$Label,

        [Parameter(Mandatory = $true)]
        [string]$Icon,

        [Parameter(Mandatory = $true)]
        [string]$Command,

        [switch]$HasShield
    )

    Set-PostTinyRegistryDefaultValue -Path $BasePath -Value $Label
    Set-PostTinyRegistryValue -Path $BasePath -Name 'Icon' -Value $Icon -Type String
    if ($HasShield) {
        Set-PostTinyRegistryValue -Path $BasePath -Name 'HasLUAShield' -Value '' -Type String
    }
    Set-PostTinyRegistryDefaultValue -Path (Join-Path $BasePath 'command') -Value $Command
}

function Invoke-PostTinyAddDeveloperContextMenu {
    Write-PostTinySection -Title 'Developer Context Menu'

    $classesPath = 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Classes'
    $cmdCommand = 'cmd.exe /s /k pushd "%V"'
    $psCommand = 'cmd /c pushd "%V" && start powershell -NoExit'
    $psAdminCommand = 'powershell.exe -Command "Start-Process powershell -Verb RunAs -ArgumentList ''-NoExit -Command Set-Location -LiteralPath ''''%V''''''"'

    Set-PostTinyContextMenuCommand -BasePath (Join-Path $classesPath 'Directory\Background\shell\cmdhere') -Label 'CMD here' -Icon 'cmd.exe' -Command $cmdCommand
    Set-PostTinyContextMenuCommand -BasePath (Join-Path $classesPath 'Directory\shell\cmdhere') -Label 'CMD here' -Icon 'cmd.exe' -Command $cmdCommand
    Set-PostTinyContextMenuCommand -BasePath (Join-Path $classesPath 'Directory\Background\shell\pshere') -Label 'PowerShell here' -Icon 'powershell.exe' -Command $psCommand
    Set-PostTinyContextMenuCommand -BasePath (Join-Path $classesPath 'Directory\shell\pshere') -Label 'PowerShell here' -Icon 'powershell.exe' -Command $psCommand
    Set-PostTinyContextMenuCommand -BasePath (Join-Path $classesPath 'Directory\Background\shell\psadmin') -Label 'PowerShell here (Admin)' -Icon 'powershell.exe' -Command $psAdminCommand -HasShield
    Set-PostTinyContextMenuCommand -BasePath (Join-Path $classesPath 'Directory\shell\psadmin') -Label 'PowerShell here (Admin)' -Icon 'powershell.exe' -Command $psAdminCommand -HasShield
}

function Invoke-PostTinyConfigureWindowsUpdate {
    Write-PostTinySection -Title 'Windows Update'

    Set-PostTinyServiceStartup -ServiceName 'wuauserv' -StartupType Manual
    Set-PostTinyServiceStartup -ServiceName 'UsoSvc' -StartupType Manual
    Set-PostTinyServiceStartup -ServiceName 'WaaSMedicSvc' -StartupType Disabled -StopService

    $wuPolicyPath = 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'
    $wuSettingsPath = 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings'
    $pauseStart = (Get-Date).ToString('yyyy-MM-ddT00:00:00Z')
    $pauseEnd = (Get-Date).AddDays(800).ToString('yyyy-MM-ddT00:00:00Z')

    Set-PostTinyRegistryValue -Path $wuPolicyPath -Name 'NoAutoUpdate' -Value 0 -Type DWord
    Set-PostTinyRegistryValue -Path $wuPolicyPath -Name 'AUOptions' -Value 2 -Type DWord
    Set-PostTinyRegistryValue -Path $wuPolicyPath -Name 'NoAutoRebootWithLoggedOnUsers' -Value 1 -Type DWord
    Set-PostTinyRegistryValue -Path $wuPolicyPath -Name 'AlwaysAutoRebootAtScheduledTime' -Value 0 -Type DWord

    foreach ($valueName in @('PauseFeatureUpdatesStartTime', 'PauseQualityUpdatesStartTime', 'PauseUpdatesStartTime')) {
        Set-PostTinyRegistryValue -Path $wuSettingsPath -Name $valueName -Value $pauseStart -Type String
    }

    Set-PostTinyRegistryValue -Path $wuSettingsPath -Name 'PauseFeatureUpdatesEndTime' -Value $pauseEnd -Type String
    Set-PostTinyRegistryValue -Path $wuSettingsPath -Name 'PauseQualityUpdatesEndTime' -Value $pauseEnd -Type String
    Set-PostTinyRegistryValue -Path $wuSettingsPath -Name 'PauseUpdatesExpiryTime' -Value $pauseEnd -Type String
    Set-PostTinyRegistryValue -Path $wuSettingsPath -Name 'ActiveHoursStart' -Value 8 -Type DWord
    Set-PostTinyRegistryValue -Path $wuSettingsPath -Name 'ActiveHoursEnd' -Value 20 -Type DWord
    Set-PostTinyRegistryValue -Path $wuSettingsPath -Name 'IsExpedited' -Value 0 -Type DWord
    Set-PostTinyRegistryValue -Path $wuSettingsPath -Name 'SmartActiveHoursState' -Value 1 -Type DWord
}

function Invoke-PostTinyRemoveOneDriveSetup {
    Write-PostTinySection -Title 'OneDrive Setup'

    foreach ($path in @(
            (Join-Path $env:SystemRoot 'System32\OneDriveSetup.exe'),
            (Join-Path $env:SystemRoot 'SysWOW64\OneDriveSetup.exe')
        )) {
        if (Remove-PostTinyPath -Path $path) {
            Write-Host "  Removed: $path" -ForegroundColor Green
        }
    }
}

function Invoke-PostTinyRemovePCManager {
    Write-PostTinySection -Title 'Microsoft PC Manager'

    Remove-PostTinyPackagesByIdentity -Identities @('Microsoft.MicrosoftPCManager') | Out-Null

    foreach ($path in @(
            'C:\Program Files\Microsoft PC Manager',
            'C:\Program Files (x86)\Microsoft PC Manager'
        )) {
        if (Remove-PostTinyPath -Path $path) {
            Write-Host "  Removed: $path" -ForegroundColor Green
        }
    }
}

function Invoke-PostTinyRemoveExtendedWallpapers {
    Write-PostTinySection -Title 'Extended Wallpapers'

    $packages = & Dism.exe /Online /English /Get-Packages |
        Select-String -Pattern 'Microsoft-Windows-Wallpaper-Content-Extended' |
        ForEach-Object { ($_ -split ':', 2)[1].Trim() }

    foreach ($package in $packages) {
        if (-not [string]::IsNullOrWhiteSpace($package)) {
            Write-Host "  Removing: $package"
            & Dism.exe /Online /English /Remove-Package "/PackageName:$package" /NoRestart | Out-Null
        }
    }
}

function Invoke-PostTinyAction {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ActionName
    )

    switch ($ActionName) {
        'VisualEffects' { Invoke-PostTinyVisualEffects }
        'FileExplorerDeveloper' { Invoke-PostTinyFileExplorerDeveloper }
        'SponsoredApps' { Invoke-PostTinyDisableSponsoredApps }
        'DisableOneDriveBackup' { Invoke-PostTinyDisableOneDriveBackup }
        'Telemetry' { Invoke-PostTinyDisableTelemetry }
        'DisableWidgets' { Invoke-PostTinyDisableWidgets }
        'DisableSearchHighlights' { Invoke-PostTinyDisableSearchHighlights }
        'DisableXboxServices' { Invoke-PostTinyDisableXboxServices }
        'DisableExtraServices' { Invoke-PostTinyDisableExtraServices }
        'WindowsSearchManual' { Invoke-PostTinySetWindowsSearchManual }
        'LockScreenSpotlight' { Invoke-PostTinyDisableLockScreenSpotlight }
        'EdgeOptimization' { Invoke-PostTinyOptimizeEdge }
        'TraditionalContextMenu' { Invoke-PostTinyEnableTraditionalContextMenu }
        'DeveloperContextMenu' { Invoke-PostTinyAddDeveloperContextMenu }
        'WindowsUpdate' { Invoke-PostTinyConfigureWindowsUpdate }
        'RemoveOneDriveSetup' { Invoke-PostTinyRemoveOneDriveSetup }
        'RemovePCManager' { Invoke-PostTinyRemovePCManager }
        'RemoveExtendedWallpapers' { Invoke-PostTinyRemoveExtendedWallpapers }
        default { throw "Unknown PostTiny action: $ActionName" }
    }
}

function Invoke-PostTinyPresetSettings {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$Preset,

        [switch]$SkipHighRisk
    )

    $highRiskActions = @($Preset.HighRiskActions)
    foreach ($actionName in $Preset.SettingsActions) {
        if ($SkipHighRisk -and $highRiskActions -contains $actionName) {
            Write-Warning "Skipping high-risk action: $actionName"
            continue
        }

        Invoke-PostTinyAction -ActionName $actionName
    }
}

Export-ModuleMember -Function @(
    'Invoke-PostTinyVisualEffects',
    'Invoke-PostTinyFileExplorerDeveloper',
    'Invoke-PostTinyDisableSponsoredApps',
    'Invoke-PostTinyDisableOneDriveBackup',
    'Invoke-PostTinyDisableTelemetry',
    'Invoke-PostTinyDisableWidgets',
    'Invoke-PostTinyDisableSearchHighlights',
    'Invoke-PostTinyDisableXboxServices',
    'Invoke-PostTinyDisableExtraServices',
    'Invoke-PostTinySetWindowsSearchManual',
    'Invoke-PostTinyDisableLockScreenSpotlight',
    'Invoke-PostTinyOptimizeEdge',
    'Invoke-PostTinyEnableTraditionalContextMenu',
    'Invoke-PostTinyAddDeveloperContextMenu',
    'Invoke-PostTinyConfigureWindowsUpdate',
    'Invoke-PostTinyRemoveOneDriveSetup',
    'Invoke-PostTinyRemovePCManager',
    'Invoke-PostTinyRemoveExtendedWallpapers',
    'Invoke-PostTinyAction',
    'Invoke-PostTinyPresetSettings'
)

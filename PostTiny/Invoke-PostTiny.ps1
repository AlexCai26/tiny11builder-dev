param (
    [ValidateSet('Menu', 'PresetCleanup', 'SelectiveAppRemoval', 'PresetSettings', 'All')]
    [string]$Mode = 'Menu',

    [string]$Preset = 'tiny11-dev',

    [switch]$SkipHighRisk
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'Modules\PostTiny.Core.psm1') -Force -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot 'Modules\PostTiny.Appx.psm1') -Force -DisableNameChecking
Import-Module (Join-Path $PSScriptRoot 'Modules\PostTiny.Settings.psm1') -Force -DisableNameChecking

function Get-PostTinyPreset {
    param (
        [Parameter(Mandatory = $true)]
        [string]$PresetName
    )

    $presetPath = Join-Path $PSScriptRoot "Presets\$PresetName.psd1"
    if (-not (Test-Path -LiteralPath $presetPath)) {
        throw "Preset file not found: $presetPath"
    }

    return Import-PowerShellDataFile -Path $presetPath
}

function Show-PostTinyMainMenu {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$Preset
    )

    Write-Host ''
    Write-Host '1. 执行 tiny11-dev 预置应用清理'
    Write-Host '2. 扫描现有预装 App 并选择删除'
    Write-Host '3. 执行 tiny11-dev 预置设置'
    Write-Host '4. 一键执行全部'
    Write-Host '5. 查看 tiny11-dev 预置摘要'
    Write-Host '0. 退出'
    Write-Host ''
    Write-Host "当前预置: $($Preset.PresetName)"
    Write-Host "高风险动作默认状态: $(if ($SkipHighRisk) { '跳过' } else { '执行' })"
}

function Show-PostTinyPresetSummary {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$Preset
    )

    Write-PostTinySection -Title 'Preset Summary'
    Write-Host "预置名称: $($Preset.PresetName)"
    Write-Host "应用清理项: $(@($Preset.AppIdentities).Count)"
    Write-Host "设置动作项: $(@($Preset.SettingsActions).Count)"
    Write-Host "高风险动作: $(@($Preset.HighRiskActions) -join ', ')"
}

function Read-PostTinySelection {
    param (
        [Parameter(Mandatory = $true)]
        [int]$MaxIndex
    )

    $raw = (Read-Host '请输入编号（支持 1,3,5 或 1-5，输入 A 全选，输入 Q 返回）').Trim()
    if ($raw -match '^[Qq]$') {
        return @()
    }

    if ($raw -match '^[Aa]$') {
        return 1..$MaxIndex
    }

    $selected = New-Object System.Collections.Generic.List[int]
    foreach ($segment in ($raw -split ',')) {
        $token = $segment.Trim()
        if (-not $token) {
            continue
        }

        if ($token -match '^(\d+)-(\d+)$') {
            $start = [int]$Matches[1]
            $end = [int]$Matches[2]
            if ($start -gt $end) {
                $temp = $start
                $start = $end
                $end = $temp
            }
            foreach ($index in $start..$end) {
                if ($index -ge 1 -and $index -le $MaxIndex -and -not $selected.Contains($index)) {
                    $selected.Add($index)
                }
            }
            continue
        }

        if ($token -match '^\d+$') {
            $index = [int]$token
            if ($index -ge 1 -and $index -le $MaxIndex -and -not $selected.Contains($index)) {
                $selected.Add($index)
            }
        }
    }

    return $selected.ToArray()
}

function Invoke-PostTinySelectiveAppRemoval {
    $inventory = @(Get-PostTinyProvisionedInventory)
    if ($inventory.Count -eq 0) {
        Write-Warning '未扫描到任何 Provisioned Appx 包。'
        return
    }

    Write-PostTinySection -Title 'Provisioned App Inventory'
    for ($index = 0; $index -lt $inventory.Count; $index++) {
        $item = $inventory[$index]
        $line = '{0,3}. {1} [{2}]' -f ($index + 1), $item.DisplayName, $item.PackageName
        Write-Host $line
    }

    $selection = @(Read-PostTinySelection -MaxIndex $inventory.Count)
    if ($selection.Count -eq 0) {
        Write-Host '未选择任何项目。'
        return
    }

    $selectedItems = foreach ($selectedIndex in $selection) {
        $inventory[$selectedIndex - 1]
    }

    Remove-PostTinyProvisionedSelection -SelectedPackages $selectedItems
}

function Invoke-PostTinyPresetCleanup {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$Preset
    )

    $summary = Remove-PostTinyPackagesByIdentity -Identities $Preset.AppIdentities
    Write-Host ''
    Write-Host '应用清理完成。'
    Write-Host "  Provisioned: $($summary.ProvisionedRemoved) / $($summary.ProvisionedMatched)"
    Write-Host "  Installed:   $($summary.InstalledRemoved) / $($summary.InstalledMatched)"
}

function Invoke-PostTinyAll {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$Preset
    )

    Invoke-PostTinyPresetCleanup -Preset $Preset
    Invoke-PostTinyPresetSettings -Preset $Preset -SkipHighRisk:$SkipHighRisk
}

$presetData = Get-PostTinyPreset -PresetName $Preset
$transcriptPath = $null

try {
    Assert-PostTinyAdministrator
    $transcriptPath = Start-PostTinyTranscriptLogging -BasePath $PSScriptRoot
    Write-PostTinyBanner -PresetName $presetData.PresetName
    Write-Host "日志文件: $transcriptPath"

    switch ($Mode) {
        'PresetCleanup' {
            Invoke-PostTinyPresetCleanup -Preset $presetData
        }
        'SelectiveAppRemoval' {
            Invoke-PostTinySelectiveAppRemoval
        }
        'PresetSettings' {
            Invoke-PostTinyPresetSettings -Preset $presetData -SkipHighRisk:$SkipHighRisk
        }
        'All' {
            Invoke-PostTinyAll -Preset $presetData
        }
        default {
            do {
                Show-PostTinyMainMenu -Preset $presetData
                $choice = (Read-Host '请选择操作').Trim()
                switch ($choice) {
                    '1' { Invoke-PostTinyPresetCleanup -Preset $presetData }
                    '2' { Invoke-PostTinySelectiveAppRemoval }
                    '3' { Invoke-PostTinyPresetSettings -Preset $presetData -SkipHighRisk:$SkipHighRisk }
                    '4' { Invoke-PostTinyAll -Preset $presetData }
                    '5' { Show-PostTinyPresetSummary -Preset $presetData }
                    '0' { break }
                    default { Write-Warning '无效选择，请重新输入。' }
                }
            } while ($choice -ne '0')
        }
    }
}
finally {
    Stop-PostTinyTranscriptLogging
}

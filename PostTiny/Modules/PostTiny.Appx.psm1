Set-StrictMode -Version Latest

Import-Module (Join-Path $PSScriptRoot 'PostTiny.Core.psm1') -Force -DisableNameChecking

function Test-PostTinyIdentityMatch {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Identity,

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Candidate
    )

    return $Candidate -like "$Identity*"
}

function Get-PostTinyProvisionedInventory {
    return Get-AppxProvisionedPackage -Online |
        Sort-Object DisplayName, PackageName |
        Select-Object DisplayName, PackageName, Version, Architecture
}

function Get-PostTinyMatchingProvisionedPackages {
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$Identities
    )

    $inventory = Get-AppxProvisionedPackage -Online
    return $inventory | Where-Object {
        $package = $_
        ($Identities | Where-Object {
                (Test-PostTinyIdentityMatch -Identity $_ -Candidate $package.DisplayName) -or
                (Test-PostTinyIdentityMatch -Identity $_ -Candidate $package.PackageName)
            }).Count -gt 0
    }
}

function Get-PostTinyMatchingInstalledPackages {
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$Identities
    )

    $installed = Get-AppxPackage -AllUsers
    return $installed | Where-Object {
        $package = $_
        ($Identities | Where-Object {
                (Test-PostTinyIdentityMatch -Identity $_ -Candidate $package.Name) -or
                (Test-PostTinyIdentityMatch -Identity $_ -Candidate $package.PackageFamilyName) -or
                (Test-PostTinyIdentityMatch -Identity $_ -Candidate $package.PackageFullName)
            }).Count -gt 0
    } | Sort-Object PackageFullName -Unique
}

function Remove-PostTinyProvisionedPackage {
    param (
        [Parameter(Mandatory = $true)]
        [string]$PackageName
    )

    try {
        Remove-AppxProvisionedPackage -Online -PackageName $PackageName -ErrorAction Stop | Out-Null
        Write-Host "  Removed provisioned package: $PackageName" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Warning "Failed to remove provisioned package '$PackageName': $_"
        return $false
    }
}

function Remove-PostTinyInstalledPackage {
    param (
        [Parameter(Mandatory = $true)]
        [string]$PackageFullName
    )

    try {
        Remove-AppxPackage -Package $PackageFullName -AllUsers -ErrorAction Stop
        Write-Host "  Removed installed package: $PackageFullName" -ForegroundColor Green
        return $true
    }
    catch {
        try {
            Remove-AppxPackage -Package $PackageFullName -ErrorAction Stop
            Write-Host "  Removed installed package (current user): $PackageFullName" -ForegroundColor Green
            return $true
        }
        catch {
            Write-Warning "Failed to remove installed package '$PackageFullName': $_"
            return $false
        }
    }
}

function Remove-PostTinyPackagesByIdentity {
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$Identities
    )

    $provisionedMatches = Get-PostTinyMatchingProvisionedPackages -Identities $Identities
    $installedMatches = Get-PostTinyMatchingInstalledPackages -Identities $Identities

    $summary = [ordered]@{
        ProvisionedMatched  = $provisionedMatches.Count
        ProvisionedRemoved  = 0
        InstalledMatched    = $installedMatches.Count
        InstalledRemoved    = 0
    }

    Write-PostTinySection -Title 'Preset App Cleanup'
    Write-Host "Matched provisioned packages: $($summary.ProvisionedMatched)"
    Write-Host "Matched installed packages: $($summary.InstalledMatched)"

    foreach ($pkg in $provisionedMatches) {
        if (Remove-PostTinyProvisionedPackage -PackageName $pkg.PackageName) {
            $summary.ProvisionedRemoved++
        }
    }

    foreach ($pkg in $installedMatches) {
        if (Remove-PostTinyInstalledPackage -PackageFullName $pkg.PackageFullName) {
            $summary.InstalledRemoved++
        }
    }

    return [pscustomobject]$summary
}

function Remove-PostTinyProvisionedSelection {
    param (
        [Parameter(Mandatory = $true)]
        [object[]]$SelectedPackages
    )

    Write-PostTinySection -Title 'Selective App Removal'
    foreach ($package in $SelectedPackages) {
        Remove-PostTinyProvisionedPackage -PackageName $package.PackageName | Out-Null

        $installedMatches = Get-PostTinyMatchingInstalledPackages -Identities @($package.DisplayName)
        foreach ($installed in $installedMatches) {
            Remove-PostTinyInstalledPackage -PackageFullName $installed.PackageFullName | Out-Null
        }
    }
}

Export-ModuleMember -Function @(
    'Get-PostTinyProvisionedInventory',
    'Get-PostTinyMatchingProvisionedPackages',
    'Get-PostTinyMatchingInstalledPackages',
    'Remove-PostTinyPackagesByIdentity',
    'Remove-PostTinyProvisionedSelection'
)

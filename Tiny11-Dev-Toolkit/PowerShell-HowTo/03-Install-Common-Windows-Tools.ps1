# Install common Windows command-line tools on demand.
$features = @(
    'TelnetClient',
    'TFTP',
    'OpenSSH.Client'
)

foreach ($featureName in $features) {
    Write-Host "Checking feature: $featureName"
    $feature = Get-WindowsCapability -Online | Where-Object Name -like "$featureName*"

    if (-not $feature) {
        $optionalFeature = Get-WindowsOptionalFeature -Online -FeatureName $featureName -ErrorAction SilentlyContinue
        if ($optionalFeature) {
            if ($optionalFeature.State -eq 'Enabled') {
                Write-Host "  Already enabled via Optional Features."
            }
            else {
                Enable-WindowsOptionalFeature -Online -FeatureName $featureName -All -NoRestart | Out-Null
                Write-Host "  Enabled via Optional Features."
            }
        }
        else {
            Write-Host "  Feature not found on this image." -ForegroundColor Yellow
        }
        continue
    }

    if ($feature.State -eq 'Installed') {
        Write-Host "  Already installed."
    }
    else {
        Add-WindowsCapability -Online -Name $feature.Name | Out-Null
        Write-Host "  Installed."
    }
}

Write-Host ""
Write-Host "Done. You can test with:"
Write-Host "  telnet"
Write-Host "  tftp"
Write-Host "  ssh"

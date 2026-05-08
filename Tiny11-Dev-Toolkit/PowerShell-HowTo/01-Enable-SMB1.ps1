# Enable SMB 1.0/CIFS client support for legacy NAS and devices.
$featureName = 'SMB1Protocol-Client'

Write-Host "Checking Windows Optional Feature: $featureName"
$feature = Get-WindowsOptionalFeature -Online -FeatureName $featureName

if ($feature.State -eq 'Enabled') {
    Write-Host "SMB 1.0/CIFS client is already enabled."
    exit 0
}

Enable-WindowsOptionalFeature -Online -FeatureName $featureName -All -NoRestart
Write-Host ""
Write-Host "SMB 1.0/CIFS client has been enabled."
Write-Host "A restart may be required before old devices become accessible."

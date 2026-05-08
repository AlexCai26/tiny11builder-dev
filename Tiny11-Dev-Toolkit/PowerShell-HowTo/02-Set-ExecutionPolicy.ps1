# Set a safer default PowerShell execution policy for the current user.
$recommendedPolicy = 'RemoteSigned'

Write-Host "Current execution policies:"
Get-ExecutionPolicy -List | Format-Table -AutoSize

Write-Host ""
Write-Host "Setting CurrentUser execution policy to $recommendedPolicy ..."
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy $recommendedPolicy -Force

Write-Host ""
Write-Host "Updated execution policies:"
Get-ExecutionPolicy -List | Format-Table -AutoSize

Write-Host ""
Write-Host "Tip: for one-time script execution, prefer:"
Write-Host "  powershell -ExecutionPolicy Bypass -File .\script.ps1"

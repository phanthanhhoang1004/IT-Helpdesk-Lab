
# Get-ADUserReport.ps1
# Export Active Directory user information to CSV

Import-Module ActiveDirectory

$ReportPath = "C:\IT-Helpdesk-Lab\Reports"

# Create report folder if it does not exist
if (!(Test-Path $ReportPath)) {
    New-Item -ItemType Directory -Path $ReportPath -Force | Out-Null
}

# Retrieve AD users
$Users = Get-ADUser -Filter * -SearchBase "OU=Users,OU=Company,DC=ad,DC=lab,DC=test" `
    -Properties Department, Enabled, LastLogonDate, EmailAddress

# Build report
$Report = foreach ($User in $Users) {
    [PSCustomObject]@{
        Name           = $User.Name
        Username       = $User.SamAccountName
        Department     = $User.Department
        Email          = $User.EmailAddress
        Enabled        = $User.Enabled
        LastLogonDate  = $User.LastLogonDate
    }
}

# Export CSV
$OutputFile = Join-Path $ReportPath "AD_User_Report.csv"

$Report | Export-Csv -Path $OutputFile -NoTypeInformation -Encoding UTF8

Write-Host "Active Directory user report exported successfully!" -ForegroundColor Green
Write-Host "Report location: $OutputFile" -ForegroundColor Cyan

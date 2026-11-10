
# Test-NetworkConnectivity.ps1
# Basic network connectivity checks for IT Support

param(
    [string]$ServerIP = "192.168.50.10",
    [string]$ServerName = "WIN-SERVER.ad.lab.test"
)

Write-Host "`n===== NETWORK CONNECTIVITY TEST =====" -ForegroundColor Cyan

# 1. Test server reachability
Write-Host "`n[1] Server Ping Test" -ForegroundColor Yellow

Test-Connection -ComputerName $ServerIP -Count 2 -Quiet

# 2. Test DNS resolution
Write-Host "`n[2] DNS Resolution Test" -ForegroundColor Yellow

try {
    Resolve-DnsName -Name $ServerName -ErrorAction Stop |
        Select-Object Name, Type, IPAddress |
        Format-Table -AutoSize
}
catch {
    Write-Host "DNS resolution failed: $($_.Exception.Message)" -ForegroundColor Red
}

# 3. Test required service ports
Write-Host "`n[3] Server Service Port Test" -ForegroundColor Yellow

$PortResults = foreach ($Port in $Ports) {
    $Result = Test-NetConnection `
        -ComputerName $ServerIP `
        -Port $Port `
        -WarningAction SilentlyContinue

    [PSCustomObject]@{
        Server = $ServerIP
        Port   = $Port
        Status = if ($Result.TcpTestSucceeded) {
            "Open"
        } else {
            "Failed"
        }
    }
}

$PortResults | Format-Table -AutoSize

Write-Host "`n===== TEST COMPLETED =====" -ForegroundColor Cyan

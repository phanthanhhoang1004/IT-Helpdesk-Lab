
# Get-ComputerInfo.ps1
# Collect basic computer and network information

$Computer = Get-CimInstance Win32_ComputerSystem
$OS = Get-CimInstance Win32_OperatingSystem

Write-Host "`n===== COMPUTER INFORMATION =====" -ForegroundColor Cyan

[PSCustomObject]@{
    ComputerName = $Computer.Name
    Domain       = $Computer.Domain
    Manufacturer = $Computer.Manufacturer
    Model        = $Computer.Model
    OS           = $OS.Caption
    Version      = $OS.Version
    LastBoot     = $OS.LastBootUpTime
} | Format-List

Write-Host "===== NETWORK INFORMATION =====" -ForegroundColor Cyan

Get-NetIPConfiguration |
    Where-Object { $_.IPv4Address } |
    Select-Object InterfaceAlias,
        @{Name="IPv4"; Expression={$_.IPv4Address.IPAddress -join ", "}},
        @{Name="Gateway"; Expression={$_.IPv4DefaultGateway.NextHop -join ", "}},
        @{Name="DNS"; Expression={$_.DNSServer.ServerAddresses -join ", "}} |
    Format-Table -AutoSize

Write-Host "===== DISK INFORMATION =====" -ForegroundColor Cyan

Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" |
    Select-Object DeviceID,
        @{Name="Size(GB)"; Expression={[math]::Round($_.Size / 1GB, 2)}},
        @{Name="Free(GB)"; Expression={[math]::Round($_.FreeSpace / 1GB, 2)}} |
    Format-Table -AutoSize

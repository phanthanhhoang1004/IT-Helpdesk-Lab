# Enterprise IT Helpdesk & Infrastructure Support Lab
## Deployment and Verification Guide

Tài liệu hướng dẫn triển khai và kiểm chứng mô hình hạ tầng IT nội bộ sử dụng VMware Workstation, Windows Server 2022 và Windows 10 Pro.

Người đọc có thể sử dụng tài liệu này để xây dựng lại môi trường lab, cấu hình các dịch vụ hạ tầng và thực hiện các bước kiểm tra sau khi triển khai.

---

# Table of Contents

1. [Lab Overview](#1-lab-overview)
2. [VMware Network Configuration](#2-vmware-network-configuration)
3. [Windows Server Initial Configuration](#3-windows-server-initial-configuration)
4. [Active Directory Domain Services](#4-active-directory-domain-services)
5. [DNS Server Configuration](#5-dns-server-configuration)
6. [DHCP Server Configuration](#6-dhcp-server-configuration)
7. [Windows Client Configuration](#7-windows-client-configuration)
8. [Group Policy Management](#8-group-policy-management)
9. [File Server and NTFS Permissions](#9-file-server-and-ntfs-permissions)
10. [Department Drive Mapping](#10-department-drive-mapping)
11. [PowerShell IT Administration Toolkit](#11-powershell-it-administration-toolkit)
12. [Final Verification](#12-final-verification)
13. [Troubleshooting](#13-troubleshooting)

---

# 1. Lab Overview

## 1.1. Objectives

The purpose of this project is to build a small enterprise IT infrastructure environment and practice common IT administration and helpdesk operations.

Main objectives:

- Configure a virtual network using VMware Workstation.
- Deploy Windows Server 2022.
- Install and configure Active Directory Domain Services.
- Configure internal DNS and DHCP services.
- Join Windows 10 clients to an Active Directory domain.
- Manage users, groups and organizational units.
- Apply Group Policy to domain users and computers.
- Configure shared folders and NTFS permissions.
- Automatically map department network drives.
- Develop PowerShell scripts for IT administration and troubleshooting.

## 1.2. Lab Environment

| Component | Configuration |
|---|---|
| Virtualization | VMware Workstation |
| Network Type | Host-only |
| Virtual Network | VMnet4 |
| Subnet | 192.168.50.0/24 |
| Server OS | Windows Server 2022 Evaluation |
| Client OS | Windows 10 Pro |
| Server Hostname | WIN-SERVER |
| Client Hostname | CLIENT01 |
| Domain | ad.lab.test |
| NetBIOS Name | AD |
| Server IP | 192.168.50.10 |
| DHCP Range | 192.168.50.100–192.168.50.150 |

## 1.3. Network Architecture

```text
                  VMware Workstation
                         |
                  VMnet4 - Host-only
                   192.168.50.0/24
                         |
             +-----------+-----------+
             |                       |
       WIN-SERVER                 CLIENT01
   Windows Server 2022          Windows 10 Pro
     192.168.50.10              DHCP Address
             |                       |
    +--------+--------+              |
    |        |        |              |
   AD DS    DNS      DHCP            |
    |        |        |              |
    +--------+--------+              |
             |                       |
       File Server ------------------+
             |
       Department Shares
       /       |        \
      IT       HR    Accounting
```

---

# 2. VMware Network Configuration

## 2.1. Configure VMnet4

**Location:** VMware Workstation on the host computer.

1. Open VMware Workstation.
2. Select `Edit` → `Virtual Network Editor`.
3. Select VMnet4 or create a new virtual network.
4. Set the network type to `Host-only`.
5. Configure the subnet:

```text
Subnet IP:   192.168.50.0
Subnet Mask: 255.255.255.0
```

6. Disable VMware DHCP because DHCP will be provided by Windows Server.
7. Apply the configuration.

## 2.2. Configure Virtual Machines

For both WIN-SERVER and CLIENT01:

1. Open Virtual Machine Settings.
2. Select Network Adapter.
3. Choose `Custom: Specific virtual network`.
4. Select `VMnet4`.

## 2.3. Verify Host Network

**Location:** Windows host computer.

Run Command Prompt:

```cmd
ipconfig
```

Expected result:

The VMware Network Adapter VMnet4 should have an address in the `192.168.50.0/24` subnet.

In this lab, the host adapter uses:

```text
192.168.50.1
```

---

# 3. Windows Server Initial Configuration

**Location:** WIN-SERVER – Windows Server 2022.

## 3.1. Rename the Server

Open PowerShell as Administrator:

```powershell
Rename-Computer -NewName "WIN-SERVER" -Restart
```

The server restarts with the new hostname.

Verify:

```powershell
hostname
```

Expected result:

```text
WIN-SERVER
```

## 3.2. Configure Static IP Address

Open:

`Server Manager` → `Local Server` → `Ethernet` → `Properties` → `Internet Protocol Version 4 (TCP/IPv4)`.

Configure:

| Setting | Value |
|---|---|
| IP Address | 192.168.50.10 |
| Subnet Mask | 255.255.255.0 |
| Default Gateway | Leave blank |
| Preferred DNS | 192.168.50.10 |

The gateway is left blank because this isolated lab does not require internet routing.

Verify the configuration:

```powershell
ipconfig /all
```

Expected configuration:

```text
IPv4 Address: 192.168.50.10
Subnet Mask:  255.255.255.0
DNS Server:   192.168.50.10
```

---

# 4. Active Directory Domain Services

## 4.1. Install AD DS

**Location:** WIN-SERVER.

Open:

`Server Manager` → `Manage` → `Add Roles and Features`.

1. Select Role-based or feature-based installation.
2. Select WIN-SERVER.
3. Select `Active Directory Domain Services`.
4. Add the required features.
5. Complete the installation.

Alternatively, use PowerShell:

```powershell
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
```

Verify:

```powershell
Get-WindowsFeature AD-Domain-Services
```

Expected result:

```text
[X] Active Directory Domain Services
```

## 4.2. Promote the Server to a Domain Controller

In Server Manager:

1. Click the notification flag.
2. Select `Promote this server to a domain controller`.
3. Choose `Add a new forest`.
4. Enter the root domain:

```text
ad.lab.test
```

5. Configure the DSRM password.
6. Complete the wizard and install.
7. Restart the server when prompted.

The server becomes the domain controller for `ad.lab.test`.

## 4.3. Verify the Domain

Run:

```powershell
Get-ADDomain
```

Expected information:

```text
DNSRoot:   ad.lab.test
NetBIOSName: AD
```

Check the domain controller:

```powershell
Get-ADDomainController
```

## 4.4. Create Organizational Units

Open:

`Server Manager` → `Tools` → `Active Directory Users and Computers`.

Create the following structure:

```text
ad.lab.test
└── Company
    ├── Users
    │   ├── IT
    │   ├── HR
    │   └── Accounting
    ├── Groups
    ├── Computers
    └── Service Accounts
```

## 4.5. Create Domain Users

Under the appropriate department OU, create user accounts.

Example:

| Department | Example Account |
|---|---|
| IT | it.staff |
| HR | hr.staff |
| Accounting | acc.staff |

Use the actual usernames configured in the lab if they differ from these examples.

To verify domain users:

```powershell
Get-ADUser -Filter * -SearchBase "OU=Users,OU=Company,DC=ad,DC=lab,DC=test" |
Select-Object Name, SamAccountName, Enabled
```

## 4.6. Create Security Groups

Create the following Global Security Groups under `Company → Groups`:

```text
GG_IT
GG_HR
GG_Accounting
GG_Managers
```

Add the appropriate users to each group.

Verify group membership:

```powershell
Get-ADGroupMember GG_IT
Get-ADGroupMember GG_HR
Get-ADGroupMember GG_Accounting
```

Expected result:

Each group should contain the users assigned to its department.

---

# 5. DNS Server Configuration

**Location:** WIN-SERVER.

DNS is installed as part of the domain controller deployment.

## 5.1. Verify DNS Service

Open PowerShell:

```powershell
Get-Service DNS
```

Expected result:

```text
Status: Running
```

## 5.2. Verify DNS Zone

Open:

`Server Manager` → `Tools` → `DNS`.

Expand:

```text
WIN-SERVER
└── Forward Lookup Zones
    └── ad.lab.test
```

The zone should contain the relevant domain records.

## 5.3. Test DNS Resolution on the Server

Run:

```powershell
nslookup WIN-SERVER.ad.lab.test
```

Expected result:

```text
Name:    WIN-SERVER.ad.lab.test
Address: 192.168.50.10
```

## 5.4. Test DNS Resolution on CLIENT01

**Location:** CLIENT01.

Run:

```cmd
nslookup WIN-SERVER.ad.lab.test
```

Expected result:

The hostname should resolve to:

```text
192.168.50.10
```

If resolution fails, check that the client's DNS server points to `192.168.50.10`.

---

# 6. DHCP Server Configuration

**Location:** WIN-SERVER.

## 6.1. Install DHCP Server

Open:

`Server Manager` → `Manage` → `Add Roles and Features`.

Select `DHCP Server` and complete the installation.

Or run:

```powershell
Install-WindowsFeature DHCP -IncludeManagementTools
```

## 6.2. Authorize DHCP Server

Complete the DHCP post-installation configuration in Server Manager.

The DHCP server must be authorized in Active Directory before it can lease addresses in this domain environment.

Verify:

```powershell
Get-DhcpServerInDC
```

## 6.3. Create DHCP Scope

Open:

`Server Manager` → `Tools` → `DHCP`.

Expand:

```text
WIN-SERVER
└── IPv4
```

Create a new scope:

| Setting | Value |
|---|---|
| Scope Name | Employee-LAN |
| Start IP | 192.168.50.100 |
| End IP | 192.168.50.150 |
| Subnet Mask | 255.255.255.0 |
| Lease Duration | 8 days |

Configure the scope options:

| Option | Value |
|---|---|
| Router (003) | Leave blank |
| DNS Server (006) | 192.168.50.10 |
| DNS Domain Name (015) | ad.lab.test |

Activate the scope.

## 6.4. Verify DHCP Scope

On WIN-SERVER:

```powershell
Get-DhcpServerv4Scope
```

Expected result:

```text
ScopeId: 192.168.50.0
Name: Employee-LAN
State: Active
```

Check leases:

```powershell
Get-DhcpServerv4Lease -ScopeId 192.168.50.0
```

Leases will appear after clients request DHCP addresses.

---

# 7. Windows Client Configuration

**Location:** CLIENT01 – Windows 10 Pro.

## 7.1. Configure Network Adapter

Set the network adapter to VMnet4.

Open:

`Control Panel` → `Network and Internet` → `Network Connections` → `Ethernet` → `Properties` → `Internet Protocol Version 4 (TCP/IPv4)`.

Choose:

```text
Obtain an IP address automatically
Obtain DNS server address automatically
```

## 7.2. Request an IP Address

Open Command Prompt as Administrator:

```cmd
ipconfig /release
ipconfig /renew
```

Verify:

```cmd
ipconfig /all
```

Expected configuration:

```text
IPv4 Address: 192.168.50.100 - 192.168.50.150
DNS Server:   192.168.50.10
DNS Suffix:   ad.lab.test
```

The exact assigned IP may vary within the DHCP scope.

## 7.3. Test Network Connectivity

Run:

```cmd
ping 192.168.50.10
```

Expected result:

```text
Reply from 192.168.50.10
```

Test DNS:

```cmd
nslookup WIN-SERVER.ad.lab.test
```

Test hostname connectivity:

```cmd
ping WIN-SERVER
```

## 7.4. Join the Domain

Open:

`Settings` → `System` → `About` → `Advanced system settings` → `Computer Name` → `Change`.

Select Domain and enter:

```text
ad.lab.test
```

Enter authorized domain credentials when prompted.

After successful domain joining, restart the client.

## 7.5. Verify Domain Membership

Run:

```cmd
systeminfo | findstr /B /C:"Host Name" /C:"Domain"
```

Expected result:

```text
Host Name: CLIENT01
Domain:    ad.lab.test
```

Or use PowerShell:

```powershell
(Get-CimInstance Win32_ComputerSystem).Domain
```

Expected result:

```text
ad.lab.test
```

## 7.6. Move Client Computer Object

On WIN-SERVER, open:

`Active Directory Users and Computers`.

Locate CLIENT01 under the default Computers container and move it to:

```text
Company → Computers
```

Verify using:

```powershell
Get-ADComputer CLIENT01
```

---

# 8. Group Policy Management

**Location:** WIN-SERVER.

Group Policy is used to centrally manage user and computer settings.

## 8.1. Configure User Policy

Open:

`Server Manager` → `Tools` → `Group Policy Management`.

Create:

```text
GPO-IT-Workstation-Policy
```

Link it to:

```text
Company → Users → IT
```

Example configuration:

`User Configuration` → `Policies` → `Administrative Templates` → `Control Panel` → `Personalization`.

Configure:

- Enable screen saver.
- Password protect the screen saver.
- Set screen saver timeout to 600 seconds.

The exact policies available depend on the Windows administrative templates installed.

## 8.2. Configure Computer Firewall Policy

Create:

```text
GPO-Computer-Firewall-Policy
```

Link it to:

```text
Company → Computers
```

Configure:

`Computer Configuration` → `Policies` → `Windows Settings` → `Security Settings` → `Windows Defender Firewall with Advanced Security`.

Configure the Domain, Private and Public profiles:

| Setting | Value |
|---|---|
| Firewall State | On |
| Inbound Connections | Block |
| Outbound Connections | Allow |

## 8.3. Apply Group Policy

On CLIENT01, sign in using a domain account affected by the policy.

Run:

```cmd
gpupdate /force
```

Expected result:

```text
Computer Policy update has completed successfully.
User Policy update has completed successfully.
```

Some policies may require signing out or restarting.

## 8.4. Verify User Policy

Run:

```cmd
gpresult /r /scope user
```

Check the Applied Group Policy Objects section.

Expected result:

```text
GPO-IT-Workstation-Policy
```

The policy should appear for an account in the IT OU.

## 8.5. Verify Computer Policy

Run:

```cmd
gpresult /r /scope computer
```

Check whether:

```text
GPO-Computer-Firewall-Policy
```

appears in the applied computer policies.

If the GPO does not appear, verify the computer account's OU, security filtering, GPO link and replication/application status.

## 8.6. Verify Firewall Profiles

On CLIENT01, run PowerShell:

```powershell
Get-NetFirewallProfile |
Select-Object Name, Enabled, DefaultInboundAction, DefaultOutboundAction
```

Expected configuration:

```text
Domain   True   Block   Allow
Private  True   Block   Allow
Public   True   Block   Allow
```

The result should reflect the policy configuration applied to the client.

---

# 9. File Server and NTFS Permissions

**Location:** WIN-SERVER.

## 9.1. Create Department Folders

Create the root folder:

```powershell
New-Item -Path "C:\DepartmentShares" -ItemType Directory -Force
```

Create department folders:

```powershell
New-Item -Path "C:\DepartmentShares\IT" -ItemType Directory -Force
New-Item -Path "C:\DepartmentShares\HR" -ItemType Directory -Force
New-Item -Path "C:\DepartmentShares\Accounting" -ItemType Directory -Force
```

The lab uses drive C: for the department shares because of the available storage capacity.

## 9.2. Configure NTFS Permissions

Open:

`File Explorer` → `C:\DepartmentShares` → select a department folder → `Properties` → `Security` → `Advanced`.

Configure access according to department membership.

| Principal | Permission |
|---|---|
| SYSTEM | Full Control |
| Administrators | Full Control |
| GG_IT | Modify on IT folder |
| GG_HR | Modify on HR folder |
| GG_Accounting | Modify on Accounting folder |

Apply department permissions to the corresponding folders.

Disable inheritance where appropriate and remove unnecessary broad permissions.

Do not remove SYSTEM or Administrators access.

## 9.3. Create SMB Shares

Open:

`Server Manager` → `File and Storage Services` → `Shares`.

Create the following shares:

| Folder | Share Name | UNC Path |
|---|---|---|
| IT | IT | \\WIN-SERVER\IT |
| HR | HR | \\WIN-SERVER\HR |
| Accounting | Accounting | \\WIN-SERVER\Accounting |

Configure share permissions:

- Authenticated Users: Change and Read.
- Administrators: Full Control.

NTFS permissions remain responsible for department-level access control.

## 9.4. Verify Shares

On WIN-SERVER:

```powershell
Get-SmbShare
```

Expected shares include:

```text
IT
HR
Accounting
```

Check share access paths:

```powershell
Get-SmbShare | Select-Object Name, Path
```

---

# 10. Department Drive Mapping

**Location:** WIN-SERVER – Group Policy Management.

The purpose is to automatically map a department's shared folder when a user signs in.

## 10.1. Create Drive Mapping GPO

Create:

```text
GPO-Department-Drive-Mapping
```

Link it to:

```text
Company → Users
```

Set Security Filtering to:

```text
Authenticated Users
```

## 10.2. Configure Drive Maps

Edit the GPO:

`User Configuration` → `Preferences` → `Windows Settings` → `Drive Maps`.

Create three mapped drives.

| Drive Letter | UNC Path | Label | Targeting Group |
|---|---|---|---|
| I: | \\WIN-SERVER\IT | IT Department | GG_IT |
| H: | \\WIN-SERVER\HR | HR Department | GG_HR |
| A: | \\WIN-SERVER\Accounting | Accounting Department | GG_Accounting |

For each mapping:

1. Select Action: Update.
2. Enable Reconnect.
3. Configure the drive letter and UNC path.
4. Open the Common tab.
5. Enable Item-level targeting.
6. Open Targeting.
7. Add a Security Group condition.
8. Select the correct AD security group using the object picker.

Select the actual domain group object rather than manually typing a group name.

## 10.3. Apply Drive Mapping

On CLIENT01:

```cmd
gpupdate /force
```

Sign out and sign in again if necessary.

## 10.4. Verify Department Drives

Run:

```cmd
net use
```

Or open:

`File Explorer` → `This PC`.

Expected result:

| User Group | Expected Drive |
|---|---|
| GG_IT | I: IT Department |
| GG_HR | H: HR Department |
| GG_Accounting | A: Accounting Department |

Each account should receive only its corresponding department drive.

## 10.5. Verify Access Control

Sign in with each department account and test the corresponding share.

Examples:

```text
\\WIN-SERVER\IT
\\WIN-SERVER\HR
\\WIN-SERVER\Accounting
```

Expected behavior:

- IT users can access the IT share.
- HR users can access the HR share.
- Accounting users can access the Accounting share.
- Users should not be able to access another department's restricted folder.

The mapped drive and NTFS permissions should both be checked.

---

# 11. PowerShell IT Administration Toolkit

The project includes three PowerShell scripts designed to support basic IT administration and troubleshooting.

Repository location:

```text
Scripts/
└── PowerShell/
    ├── Get-ComputerInfo.ps1
    ├── Test-NetworkConnectivity.ps1
    └── Get-ADUserReport.ps1
```

## 11.1. Get-ComputerInfo.ps1

**Purpose:** Collect basic computer information, operating system details, network configuration and disk information.

**Location:** WIN-SERVER or another supported Windows computer.

Open PowerShell and navigate to the script directory:

```powershell
cd "C:\IT-Helpdesk-Lab\Scripts\PowerShell"
```

Run:

```powershell
.\Get-ComputerInfo.ps1
```

Expected information includes:

- Computer name.
- Domain information.
- Operating system.
- Network configuration.
- Disk information.

The exact displayed fields depend on the script implementation.

## 11.2. Test-NetworkConnectivity.ps1

**Purpose:** Test connectivity between the client and the Windows Server.

**Location:** CLIENT01.

Run:

```powershell
cd "C:\IT-Helpdesk-Lab\Scripts\PowerShell"
```

If execution policy blocks the script, allow script execution for the current PowerShell process only:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

Run:

```powershell
.\Test-NetworkConnectivity.ps1
```

The script checks the following services and network functions:

| Test | Purpose |
|---|---|
| Ping | Verify basic IP connectivity |
| DNS Resolution | Verify server hostname resolution |
| TCP 53 | DNS connectivity |
| TCP 389 | LDAP connectivity |
| TCP 445 | SMB file sharing connectivity |

Expected results:

- Server responds to ping.
- Server hostname resolves to 192.168.50.10.
- Required TCP ports are reachable.

A failed test should be investigated rather than treated as a successful verification.

## 11.3. Get-ADUserReport.ps1

**Purpose:** Retrieve Active Directory user information and export it to a CSV report.

**Location:** WIN-SERVER.

Open PowerShell as Administrator:

```powershell
cd "C:\IT-Helpdesk-Lab\Scripts\PowerShell"
```

Run:

```powershell
.\Get-ADUserReport.ps1
```

The script uses the Active Directory PowerShell module and exports a report to:

```text
C:\IT-Helpdesk-Lab\Reports\AD_User_Report.csv
```

The report includes fields such as:

- Name.
- SamAccountName.
- Department.
- EmailAddress.
- Enabled.
- LastLogonDate.

Verify the output:

```powershell
Test-Path "C:\IT-Helpdesk-Lab\Reports\AD_User_Report.csv"
```

Expected result:

```text
True
```

Open the report:

```powershell
Import-Csv "C:\IT-Helpdesk-Lab\Reports\AD_User_Report.csv" |
Format-Table -AutoSize
```

Note: The script requires the Active Directory PowerShell module and appropriate permissions.

---

# 12. Final Verification

After completing the deployment, perform a final verification of the environment.

## 12.1. Server Verification

**Location:** WIN-SERVER.

Check hostname:

```powershell
hostname
```

Check IP configuration:

```powershell
ipconfig /all
```

Check important services:

```powershell
Get-Service DNS, DHCPServer, NTDS
```

Check domain:

```powershell
Get-ADDomain
```

Check DHCP scope:

```powershell
Get-DhcpServerv4Scope
```

Check SMB shares:

```powershell
Get-SmbShare
```

## 12.2. Client Verification

**Location:** CLIENT01.

Check IP configuration:

```cmd
ipconfig /all
```

Check server connectivity:

```cmd
ping 192.168.50.10
```

Check DNS:

```cmd
nslookup WIN-SERVER.ad.lab.test
```

Check domain membership:

```powershell
(Get-CimInstance Win32_ComputerSystem).Domain
```

Check applied policies:

```cmd
gpresult /r
```

Check mapped drives:

```cmd
net use
```

## 12.3. Final Acceptance Checklist

| Item | Expected Result |
|---|---|
| VMware Network | WIN-SERVER and CLIENT01 connected to VMnet4 |
| Server IP | 192.168.50.10 |
| Active Directory | Domain ad.lab.test operational |
| DNS | Internal hostname resolution successful |
| DHCP | Client receives an address from the configured scope |
| Domain Join | CLIENT01 joined to ad.lab.test |
| Group Policy | Relevant user and computer policies applied |
| File Server | Department shares available |
| NTFS Permissions | Department access restricted appropriately |
| Drive Mapping | Correct drive mapped for each department |
| PowerShell Toolkit | Scripts execute and produce expected outputs |

---

# 13. Troubleshooting

## 13.1. Client Cannot Obtain DHCP Address

Check:

1. CLIENT01 is connected to VMnet4.
2. VMware DHCP is disabled.
3. Windows Server DHCP service is running.
4. DHCP scope is active.
5. DHCP server is authorized.

Run on CLIENT01:

```cmd
ipconfig /release
ipconfig /renew
```

Check the assigned IP:

```cmd
ipconfig
```

## 13.2. DNS Resolution Fails

Check the client DNS server:

```cmd
ipconfig /all
```

The DNS server should be:

```text
192.168.50.10
```

Test DNS:

```cmd
nslookup WIN-SERVER.ad.lab.test
```

Check DNS service on WIN-SERVER:

```powershell
Get-Service DNS
```

## 13.3. Group Policy Is Not Applied

Run on CLIENT01:

```cmd
gpupdate /force
```

Check:

```cmd
gpresult /r
```

Verify:

- The user or computer is in the correct OU.
- The GPO is linked to the correct OU.
- Security Filtering allows the intended account.
- The user or computer has permission to apply the GPO.
- The policy is not blocked or overridden by another configuration.

## 13.4. Department Drive Does Not Appear

Check:

1. The user belongs to the correct security group.
2. The drive mapping GPO is applied.
3. Item-level targeting references the correct AD group.
4. The UNC path is correct.
5. The user can access the share.

Run:

```cmd
gpupdate /force
```

Then sign out and sign in again.

Check:

```cmd
net use
```

## 13.5. Access to a Department Share Is Denied

Check both:

- SMB Share Permissions.
- NTFS Security Permissions.

Remember that effective access is determined by the combined share and NTFS permissions. A permissive share setting does not override restrictive NTFS permissions.

---

# Conclusion

This lab demonstrates the deployment and administration of a small Windows-based enterprise IT infrastructure.

The project covers virtualization, network configuration, Windows Server administration, Active Directory, DNS, DHCP, Group Policy, file sharing, access control and PowerShell automation.

The verification procedures provide a practical way to validate the configuration and troubleshoot common infrastructure issues.

**Project Status:** Core infrastructure deployment and administration toolkit completed. Further extensions may include centralized helpdesk ticketing, monitoring integration and automated incident response.

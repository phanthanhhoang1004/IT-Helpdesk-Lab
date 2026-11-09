# Enterprise IT Helpdesk & Infrastructure Support Lab

A hands-on enterprise IT infrastructure lab built with Windows Server 2022 and Windows 10 Pro to practice Active Directory administration, network services, Group Policy management, file sharing, and PowerShell automation.

## Project Overview

This project simulates a small enterprise IT environment where a Windows Server domain controller provides centralized identity management, network services, security policies, and departmental file sharing for domain-joined workstations.

The lab focuses on practical tasks commonly performed by Helpdesk, IT Support, System Administration, and Infrastructure Operations teams.

## Objectives

- Deploy and manage a Windows Server domain environment.
- Configure Active Directory users, organizational units, and security groups.
- Implement DNS and DHCP services.
- Apply centralized workstation policies using Group Policy.
- Configure secure departmental file sharing and network drive mapping.
- Develop PowerShell scripts for routine IT administration and troubleshooting.

## Lab Environment

| Component | Configuration |
|---|---|
| Hypervisor | VMware Workstation |
| Server OS | Windows Server 2022 Evaluation |
| Client OS | Windows 10 Pro |
| Network | VMware Host-only (VMnet4) |
| Domain | ad.lab.test |
| Server IP | 192.168.50.10 |
| Client IP | DHCP: 192.168.50.100–150 |

## Architecture

```text
             VMware Host-only Network
                    VMnet4
                192.168.50.0/24
                       |
          +------------+------------+
          |                         |
   Windows Server 2022        Windows 10 Pro
      WIN-SERVER                 CLIENT01
    192.168.50.10                DHCP Client
          |                         |
   +------+------+                  |
   |      |      |                  |
  AD DS  DNS    DHCP                |
   |      |      |                  |
   +------+------+-----------------+
          |
   File Server & GPO
          |
   Department Shares
   +------+------+ 
   |      |      |
   IT     HR  Accounting
```

## Implemented Modules

### 1. Active Directory Domain Services

- Installed and configured Active Directory Domain Services.
- Created the domain `ad.lab.test`.
- Designed an Organizational Unit structure for IT, HR, Accounting, Groups, Computers, and Service Accounts.
- Created domain user accounts and Global Security Groups.
- Assigned users to their corresponding departmental groups.

### 2. DNS and DHCP

- Configured internal DNS for domain name resolution.
- Installed and authorized the DHCP Server role.
- Created the `Employee-LAN` DHCP scope.
- Configured automatic IP address assignment and internal DNS settings.
- Verified client connectivity and domain name resolution.

### 3. Group Policy Management

- Created and linked user and computer Group Policy Objects.
- Configured screen saver and password protection policies.
- Applied Windows Defender Firewall policies to domain-joined workstations.
- Verified Group Policy application using `gpresult`.

### 4. File Server and Departmental Access Control

- Created departmental shared folders for IT, HR, and Accounting.
- Configured SMB shares and NTFS permissions.
- Applied access restrictions using Active Directory security groups.
- Implemented automatic network drive mapping through Group Policy Preferences.
- Used Item-level Targeting to assign drives to the appropriate departments.
- Verified departmental access using separate domain user accounts.

### 5. PowerShell IT Administration Toolkit

Developed PowerShell scripts to support common IT administration tasks.

| Script | Description |
|---|---|
| `Get-ComputerInfo.ps1` | Collects computer, operating system, network, and disk information. |
| `Test-NetworkConnectivity.ps1` | Checks server connectivity, DNS resolution, and TCP service ports. |
| `Get-ADUserReport.ps1` | Retrieves Active Directory user information and exports reports to CSV. |

## Technologies & Skills

- **Operating Systems:** Windows Server 2022, Windows 10 Pro
- **Infrastructure:** Active Directory, DNS, DHCP, File Server
- **Administration:** Group Policy, OU Management, User & Group Administration
- **Networking:** TCP/IP, IPv4, DHCP, DNS, SMB
- **Security:** NTFS Permissions, Windows Defender Firewall, Access Control
- **Automation:** PowerShell, CSV Reporting
- **Virtualization:** VMware Workstation

## Repository Structure

```text
Enterprise-IT-Helpdesk-Lab/
├── Documentation/
│   ├── Active-Directory/
|   ├── DHCP/
│   ├── Group-Policy/
│   ├── File-Server/
│   └── PowerShell/
├── Scripts/
│   └── PowerShell/
└── README.md
```

## Project Status

Core infrastructure and administration modules have been implemented and documented. GLPI-based ticketing and IT asset management are potential future extensions.

## Disclaimer

This is a personal learning and portfolio project built in a virtualized lab environment. It is intended for educational purposes and does not represent a production-ready enterprise deployment.

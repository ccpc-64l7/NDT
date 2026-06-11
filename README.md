# NDT
# Network Diagnostics Toolkit

> Beta 000.171 — verified release build for the current GitHub publish flow.

<img width="1111" height="634" alt="3d2aa029-b69c-42a8-8ca6-e96bd7839c6a" src="https://github.com/user-attachments/assets/3c2e9298-51bf-4106-84a7-9b7e3203e71e" />
NetInfo is an interactive, highly detailed PowerShell Swiss Army Knife designed for system administrators, homelabbers, and field technicians. It consolidates the most crucial Windows network troubleshooting and repair tasks into a single, clean CLI menu.

This repository is also evolving into a hybrid PowerShell + Python lab. The PowerShell front end remains the primary Windows-native interface, while Python helper scripts live alongside it for deeper DNS, OSINT, and automation workflows.

## 🚀 Features

* **Advanced IP Enumeration:** Identifies local IP routing, primary gateways, active DNS resolvers, and external public IPs with fallback Geo/ASN enrichment.
* **Network Health Diagnostics:** Automated multi-stage pinging (Gateway, External ICMP, HTTPS/DNS) to instantly locate exactly where a network chain drops.
* **Active Port & LAN Mapping:** View all listening TCP/UDP ports mapped to their specific owning processes, and dump LAN ARP tables for device discovery.
* **Network Repair (God Mode):** A one-click administrative nuke button that flushes DNS, releases/renews IPs, and completely resets the Winsock and TCP/IP stack.
* **Telemetry Bundle Export:** Generates a silent `.ZIP` file on your Desktop containing your full `ipconfig`, `netstat`, `arp`, routing tables, and speedtest results for support tickets.
* **Ookla Speedtest CLI Integration:** Automatically detects, installs (via Winget, Choco, or Scoop), and silently accepts EULAs to run official throughput benchmarks.
* **DNS Benchmarking & Tracerouting:** Compare latency across major public DNS providers (Cloudflare, Google, Quad9) and trace outbound traffic hops.
* **Wake-on-LAN:** Broadcast magic UDP packets directly from the terminal to wake remote homelab servers.

## 🛠️ Hybrid Architecture

- `NDT.ps1` remains the main interactive diagnostic interface for Windows network tasks.
- `scripts/update_release_hash.py` is the current Python helper in the repo for release and hash automation.
- Future Python modules will be added under `scripts/` to support DNS profiling, OSINT enrichment, and structured JSON output for the PowerShell UI to consume.

## 🛠️ Usage

### Quick Start
Download `NDT.ps1` and run it directly in your PowerShell terminal:

```powershell
.\NDT.ps1
```

## 🔒 Security Verification

To ensure the integrity of this script, you can verify its SHA-256 cryptographic hash against the official release build.

* **VirusTotal Status:**
* Verified clean on the published 000.171 beta asset
* Basic properties

https://www.virustotal.com/gui/file/9e279643495848430c3118030221fd4c7d250b48cd572bbf6f6d7906e8b7b9d7](https://www.virustotal.com/gui/file/7dc1f734e5a5306b80ec279ebf1ca4825155e98a3e196e4680ff99ce91d86070/details)

* **Official SHA-256 Hash:** `7dc1f734e5a5306b80ec279ebf1ca4825155e98a3e196e4680ff99ce91d86070`

To verify your local copy, run this command in PowerShell:

```powershell
Get-FileHash .\NDT.ps1
```

## 📝 Changelog — v000.171 Beta

### What changed
- Updated the top banner to the current SYSADMIN-focused 000.171 beta presentation.
- Documented the official SHA-256 hash for the final 000.171 script build.
- Refreshed the README verification guidance so the release asset and local copy can be checked consistently.

### Why
- This release keeps the beta branch aligned with the latest project-state updates and security verification workflow.
- The integrity notice and hash guidance make the current beta release easier to validate before distribution.

# NDT V 1.1.1 OUT SOON
# Network Diagnostics Toolkit

> Beta 000.172 — verified release build for the current GitHub publish flow.

<img width="968" height="513" alt="{E8614005-B8D2-4813-B1D9-B8F7ABCB3181}" src="https://github.com/user-attachments/assets/66cd3d7b-d8a1-42a0-bb41-59c4b5b2b10d" />

Network Diagnostics Toolkit (NDT) is an interactive, highly detailed PowerShell Swiss Army Knife designed for system administrators, homelabbers, and field technicians. It consolidates the most crucial Windows network troubleshooting and repair tasks into a single, clean CLI menu.

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


https://www.virustotal.com/gui/file/7dc1f734e5a5306b80ec279ebf1ca4825155e98a3e196e4680ff99ce91d86070
* **Official SHA-256 Hash:** `7dc1f734e5a5306b80ec279ebf1ca4825155e98a3e196e4680ff99ce91d86070`

To verify your local copy, run this command in PowerShell:

```powershell
Get-FileHash .\NDT.ps1
```


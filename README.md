# NDT
# NetInfo: God-Mode Network Diagnostics Toolkit

<img width="694" height="397" alt="image_818f65" src="https://github.com/user-attachments/assets/9782c3b2-0975-426e-98c0-f6aface21a30" />

NetInfo is an interactive, highly detailed PowerShell Swiss Army Knife designed for system administrators, homelabbers, and field technicians. It consolidates the most crucial Windows network troubleshooting and repair tasks into a single, clean CLI menu.

## 🚀 Features

* **Advanced IP Enumeration:** Identifies local IP routing, primary gateways, active DNS resolvers, and external public IPs with fallback Geo/ASN enrichment.
* **Network Health Diagnostics:** Automated multi-stage pinging (Gateway, External ICMP, HTTPS/DNS) to instantly locate exactly where a network chain drops.
* **Active Port & LAN Mapping:** View all listening TCP/UDP ports mapped to their specific owning processes, and dump LAN ARP tables for device discovery.
* **Network Repair (God Mode):** A one-click administrative nuke button that flushes DNS, releases/renews IPs, and completely resets the Winsock and TCP/IP stack.
* **Telemetry Bundle Export:** Generates a silent `.ZIP` file on your Desktop containing your full `ipconfig`, `netstat`, `arp`, routing tables, and speedtest results for support tickets.
* **Ookla Speedtest CLI Integration:** Automatically detects, installs (via Winget, Choco, or Scoop), and silently accepts EULAs to run official throughput benchmarks.
* **DNS Benchmarking & Tracerouting:** Compare latency across major public DNS providers (Cloudflare, Google, Quad9) and trace outbound traffic hops.
* **Wake-on-LAN:** Broadcast magic UDP packets directly from the terminal to wake remote homelab servers.

## 🛠️ Usage

### Quick Start
Download `NetInfo.ps1` and run it directly in your PowerShell terminal:

```powershell
.\NetInfo.ps1

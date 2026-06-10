#Requires -Version 5.1
<#
.SYNOPSIS
    NetInfo — God Mode Network Diagnostics & Toolkit

.DESCRIPTION
    Interactive CLI menu for:
      • Local/External IP & LAN Discovery
      • Active Listening Ports (TCP/UDP)
      • Network Diagnostics, Traceroute & DNS Benchmarking
      • Network Stack Repair (Winsock, DNS, IP)
      • Full Diagnostic Bundle Export (ZIP)
      • Ookla Speedtest CLI Integration

.NOTES
    Compat  : PowerShell 5.1+ | Windows 10 / Windows 11
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'SilentlyContinue'

# Global state for exporting
$script:ReportData = @{
    Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
    Local = $null
    External = $null
    Diagnostics = $null
}

# ═══════════════════════════════════════════════════════════════════
#  UI HELPERS
# ═══════════════════════════════════════════════════════════════════

function Write-Header {
    Clear-Host
    $banner = @"

  ╔══════════════════════════════════════════════════════╗
  ║ NDT Network Diagnostics Toolkit · SYSADMIN Edition   ║
  ╚══════════════════════════════════════════════════════╝
                · BETA VERSION 000.171 ·
"@
    Write-Host $banner -ForegroundColor Cyan
}

function Write-Section([string]$Title) {
    $pad = [math]::Max(2, 50 - $Title.Length - 4)
    Write-Host ""
    Write-Host ("  ┤ " + $Title + " ├" + ("─" * $pad)) -ForegroundColor DarkCyan
}

function Write-KV([string]$Key, [string]$Val, [ConsoleColor]$Color = 'Green') {
    if (-not [string]::IsNullOrWhiteSpace($Val)) {
        Write-Host ("    {0,-15}: " -f $Key) -NoNewline -ForegroundColor DarkGray
        Write-Host $Val -ForegroundColor $Color
    }
}

function Write-Warn([string]$Msg)  { Write-Host "  [!] $Msg" -ForegroundColor Yellow }
function Write-Err([string]$Msg)   { Write-Host "  [✗] $Msg" -ForegroundColor Red    }
function Write-Ok([string]$Msg)    { Write-Host "  [✓] $Msg" -ForegroundColor Green  }
function Write-Info([string]$Msg)  { Write-Host "  [i] $Msg" -ForegroundColor DarkGray }

function Pause-Return {
    Write-Host "`n  Press Enter to return to menu..." -ForegroundColor DarkGray
    $null = Read-Host
}

function Test-IsAdmin {
    $principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# ═══════════════════════════════════════════════════════════════════
#  CORE IP & DNS
# ═══════════════════════════════════════════════════════════════════

function Get-LocalIP {
    Write-Section "Local Network Interfaces"
    $activeAdapters = Get-NetAdapter | Where-Object Status -eq 'Up'
    
    try {
        $route = Get-NetRoute -AddressFamily IPv4 -DestinationPrefix '0.0.0.0/0' | Where-Object { $_.NextHop -ne '0.0.0.0' } | Sort-Object RouteMetric | Select-Object -First 1

        if ($route) {
            $addr = Get-NetIPAddress -InterfaceIndex $route.ifIndex -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '169.254.*' } | Select-Object -First 1
            $nic = $activeAdapters | Where-Object ifIndex -eq $route.ifIndex
            $dns = Get-DnsClientServerAddress -InterfaceIndex $route.ifIndex -AddressFamily IPv4 | Select-Object -ExpandProperty ServerAddresses

            if ($addr) {
                Write-Host "`n  ★ Primary Route" -ForegroundColor Cyan
                Write-KV "IP Address" $addr.IPAddress
                Write-KV "Subnet Prefix" "/$($addr.PrefixLength)" 'DarkGreen'
                Write-KV "Gateway" $route.NextHop 'DarkGreen'
                if ($dns) { Write-KV "DNS Servers" ($dns -join ", ") 'DarkGreen' }
                if ($nic) {
                    Write-KV "Adapter Name" $nic.Name 'DarkGreen'
                    Write-KV "Link Speed" $nic.LinkSpeed 'DarkGreen'
                }
            }
        }
    } catch { Write-Warn "Could not determine primary route." }

    Write-Host "`n  Active IPv4 Interfaces:" -ForegroundColor DarkGray
    $allIPs = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254.*' }
    if ($allIPs) {
        Write-Host ("    {0,-28} {1,-18} {2}" -f "Adapter","IP Address","Prefix") -ForegroundColor DarkGray
        Write-Host ("    " + "─" * 54) -ForegroundColor DarkGray
        foreach ($a in $allIPs) {
            $nic = $activeAdapters | Where-Object ifIndex -eq $a.InterfaceIndex
            $name = if ($nic) { $nic.Name } else { "idx:$($a.InterfaceIndex)" }
            Write-Host ("    {0,-28} {1,-18} /{2}" -f $name, $a.IPAddress, $a.PrefixLength) -ForegroundColor White
        }
    }
}

function Get-ExternalIP {
    Write-Section "External / Public IP"
    $services = @('https://ipinfo.io/ip', 'https://api.ipify.org', 'https://icanhazip.com')
    Write-Host "  Querying public IP..." -ForegroundColor DarkGray
    $ip = $null

    foreach ($svc in $services) {
        try {
            $r = (Invoke-RestMethod -Uri $svc -TimeoutSec 5 -UseBasicParsing).Trim()
            if ($r -match '^\d{1,3}(\.\d{1,3}){3}$') { $ip = $r; break }
        } catch {}
    }

    if ($ip) {
        Write-KV "Public IP" $ip "Cyan"
        try {
            $geo = Invoke-RestMethod -Uri "https://ipinfo.io/$ip/json" -TimeoutSec 5 -UseBasicParsing
            Write-KV "City/Region" "$($geo.city), $($geo.region)" 'DarkGreen'
            Write-KV "ISP / Org" $geo.org 'DarkGreen'
        } catch { Write-Info "Geo lookup unavailable." }
    } else { Write-Err "Could not reach public IP service." }
    return $ip
}

# ═══════════════════════════════════════════════════════════════════
#  ADVANCED DIAGNOSTICS & TOOLS
# ═══════════════════════════════════════════════════════════════════

function Test-NetworkHealth {
    Write-Section "Internet Reachability Test"
    
    # Gateway Ping
    $gateway = (Get-NetRoute -DestinationPrefix '0.0.0.0/0' | Sort-Object RouteMetric | Select -First 1).NextHop
    if ($gateway) {
        Write-Info "Pinging Gateway ($gateway)..."
        $pingGW = Test-Connection -ComputerName $gateway -Count 4 -ErrorAction SilentlyContinue
        if ($pingGW) { Write-Ok "Gateway is reachable" } else { Write-Err "Gateway is UNREACHABLE" }
    }

    # Public ICMP & DNS
    if (Test-NetConnection -ComputerName "1.1.1.1" -InformationLevel Quiet -WarningAction SilentlyContinue) { Write-Ok "External ICMP (1.1.1.1) OK" } else { Write-Err "External ICMP Failed" }
    if (Test-NetConnection -ComputerName "google.com" -Port 443 -InformationLevel Quiet -WarningAction SilentlyContinue) { Write-Ok "DNS & HTTPS (google.com:443) OK" } else { Write-Err "DNS/HTTPS Failed" }
}

function Get-LanDiscovery {
    Write-Section "LAN Discovery (ARP Table)"
    arp -a
}

function Get-ListeningPorts {
    Write-Section "TCP Listening Ports"
    Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
        Select-Object LocalAddress, LocalPort, @{Name='Process';Expression={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName}} |
        Sort-Object LocalPort | Format-Table -AutoSize

    Write-Section "UDP Endpoints"
    Get-NetUDPEndpoint -ErrorAction SilentlyContinue |
        Select-Object LocalAddress, LocalPort, @{Name='Process';Expression={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName}} |
        Sort-Object LocalPort | Format-Table -AutoSize
}

function Invoke-DnsBenchmark {
    Write-Section "DNS Resolvers Benchmark"
    $servers = @('1.1.1.1', '1.0.0.1', '8.8.8.8', '8.8.4.4', '9.9.9.9', '208.67.222.222')
    $results = @()
    
    Write-Info "Testing standard resolvers..."
    foreach ($s in $servers) {
        $ping = Test-Connection -ComputerName $s -Count 3 -ErrorAction SilentlyContinue | Measure-Object -Property ResponseTime -Average
        if ($ping.Count -gt 0) { $results += [pscustomobject]@{Server=$s; LatencyMs=[math]::Round($ping.Average, 2)} }
    }
    
    if ($results) {
        $sorted = $results | Sort-Object LatencyMs
        $sorted | Format-Table -AutoSize
        Write-Ok "Fastest Responder: $($sorted[0].Server) at $($sorted[0].LatencyMs) ms"
    }
}

function Invoke-TracerouteTask {
    Write-Section "Traceroute"
    $Target = Read-Host "  Enter Target (default: 1.1.1.1)"
    if ([string]::IsNullOrWhiteSpace($Target)) { $Target = "1.1.1.1" }
    Write-Info "Tracing route to $Target (This may take a minute)..."
    Test-NetConnection -ComputerName $Target -TraceRoute
}

function Send-WOL {
    Write-Section "Wake-on-LAN"
    $Mac = Read-Host "  Enter MAC Address (e.g., 00:11:22:33:44:55)"
    if ([string]::IsNullOrWhiteSpace($Mac)) { return }
    try {
        $MacByteArray = $Mac -split "[:-]" | ForEach-Object { [Byte] "0x$_"}
        $MagicPacket = (,0xFF * 6) + ($MacByteArray * 16)
        $UdpClient = New-Object System.Net.Sockets.UdpClient
        $UdpClient.Connect(([System.Net.IPAddress]::Broadcast),9)
        $UdpClient.Send($MagicPacket,$MagicPacket.Length) | Out-Null
        $UdpClient.Close()
        Write-Ok "Magic packet broadcasted for $Mac"
    } catch { Write-Err "Invalid MAC format." }
}

# ═══════════════════════════════════════════════════════════════════
#  SYSTEM REPAIR
# ═══════════════════════════════════════════════════════════════════

function Repair-Network {
    Write-Section "Network Stack Repair"
    if (-not (Test-IsAdmin)) {
        Write-Err "Administrator rights required to reset TCP/IP and Winsock."
        Write-Info "Restart PowerShell as Admin to use this feature."
        return
    }

    Write-Warn "This will reset all network adapters, clear DNS, and drop connections."
    $confirm = Read-Host "  Continue? [Y/N]"
    if ($confirm -notmatch '^[Yy]') { return }

    Write-Info "Flushing DNS Cache..."
    Clear-DnsClientCache
    ipconfig /flushdns | Out-Null

    Write-Info "Releasing and Renewing IP..."
    ipconfig /release | Out-Null
    ipconfig /renew | Out-Null
    ipconfig /registerdns | Out-Null

    Write-Info "Resetting Winsock and TCP/IP Stack..."
    netsh winsock reset | Out-Null
    netsh int ip reset | Out-Null

    Write-Ok "Network reset complete."
    Write-Warn "A SYSTEM REBOOT IS HIGHLY RECOMMENDED."
}

# ═══════════════════════════════════════════════════════════════════
#  SPEEDTEST 
# ═══════════════════════════════════════════════════════════════════

function Find-SpeedtestBinary {
    foreach ($name in @('speedtest','speedtest.exe')) {
        $c = Get-Command $name -ErrorAction SilentlyContinue
        if ($c) { return $c.Source }
    }
    $candidates = @("$env:ProgramFiles\Ookla\Speedtest CLI\speedtest.exe", "C:\ProgramData\chocolatey\bin\speedtest.exe", "$env:USERPROFILE\scoop\shims\speedtest.exe", "$env:LOCALAPPDATA\Microsoft\WinGet\Links\speedtest.exe")
    foreach ($p in $candidates) { if (Test-Path $p) { return $p } }
    return $null
}

function Invoke-Speedtest {
    Write-Section "Throughput Test (Ookla)"
    $bin = Find-SpeedtestBinary
    if (-not $bin) { Write-Err "Speedtest CLI not found. Please install via Winget/Choco."; return }
    Write-Info "Executing... (Auto-accepting EULA)"
    Write-Host ""
    & $bin --accept-license --accept-gdpr --progress=yes
}

# ═══════════════════════════════════════════════════════════════════
#  FULL BUNDLE EXPORT
# ═══════════════════════════════════════════════════════════════════

function Export-DiagnosticBundle {
    Write-Section "Full Diagnostic Bundle Generator"
    Write-Info "Gathering logs, routes, and configs..."
    
    $stamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
    $tempDir = Join-Path $env:TEMP "NetDiag_$stamp"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

    Write-Host "  [>] Dumping ipconfig..." -ForegroundColor DarkGray
    ipconfig /all > "$tempDir\ipconfig.txt"
    Write-Host "  [>] Dumping routing table..." -ForegroundColor DarkGray
    route print > "$tempDir\route_table.txt"
    Write-Host "  [>] Dumping ARP table..." -ForegroundColor DarkGray
    arp -a > "$tempDir\arp_table.txt"
    Write-Host "  [>] Dumping active network connections..." -ForegroundColor DarkGray
    netstat -ano > "$tempDir\netstat.txt"
    
    Write-Host "  [>] Fetching DNS & Public IP..." -ForegroundColor DarkGray
    Get-DnsClientServerAddress | Out-File "$tempDir\dns_servers.txt"
    $extIP = Get-ExternalIP | Out-Null
    
    $bin = Find-SpeedtestBinary
    if ($bin) {
        Write-Host "  [>] Running Speedtest (This will take ~30s)..." -ForegroundColor DarkGray
        & $bin --accept-license --accept-gdpr --format=text > "$tempDir\speedtest_result.txt"
    }

    Write-Host "  [>] Zipping bundle..." -ForegroundColor DarkGray
    $zipPath = Join-Path [Environment]::GetFolderPath("Desktop") "NetInfo_$stamp.zip"
    Compress-Archive -Path "$tempDir\*" -DestinationPath $zipPath -Force

    # Cleanup temp folder
    Remove-Item -Path $tempDir -Recurse -Force

    Write-Host ""
    Write-Ok "Diagnostic Bundle saved to:"
    Write-Host "      $zipPath" -ForegroundColor Cyan
}

# ═══════════════════════════════════════════════════════════════════
#  MENU
# ═══════════════════════════════════════════════════════════════════

function Show-Menu {
    Write-Host "  ┌────────────────────────────────────────────────────────┐" -ForegroundColor DarkCyan
    Write-Host "  │  1  Local Network & External IP                        │" -ForegroundColor White
    Write-Host "  │  2  Internet Reachability (Gateway & DNS Check)        │" -ForegroundColor White
    Write-Host "  │  3  Active Listening Ports (TCP & UDP)                 │" -ForegroundColor White
    Write-Host "  │  4  LAN Discovery (ARP Table)                          │" -ForegroundColor White
    Write-Host "  │  5  DNS Resolver Benchmark                             │" -ForegroundColor White
    Write-Host "  │  6  Traceroute                                         │" -ForegroundColor White
    Write-Host "  │  7  Run Speedtest CLI                                  │" -ForegroundColor White
    Write-Host "  ├────────────────────────────────────────────────────────┤" -ForegroundColor DarkCyan
    Write-Host "  │  8  Wake-on-LAN (WOL) Broadcaster                      │" -ForegroundColor DarkYellow
    Write-Host "  │  9  Network Stack Repair (Reset & Flush)               │" -ForegroundColor Red
    Write-Host "  ├────────────────────────────────────────────────────────┤" -ForegroundColor DarkCyan
    Write-Host "  │  0  Generate Full Diagnostic Bundle (.ZIP)             │" -ForegroundColor Cyan
    Write-Host "  │  Q  Quit                                               │" -ForegroundColor DarkGray
    Write-Host "  └────────────────────────────────────────────────────────┘" -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host "  ›  " -NoNewline -ForegroundColor Cyan
}

do {
    Write-Header
    Show-Menu
    $choice = (Read-Host).Trim().ToUpper()
    Write-Header

    switch ($choice) {
        '1' { Get-LocalIP; $null = Get-ExternalIP }
        '2' { Test-NetworkHealth }
        '3' { Get-ListeningPorts }
        '4' { Get-LanDiscovery }
        '5' { Invoke-DnsBenchmark }
        '6' { Invoke-TracerouteTask }
        '7' { Invoke-Speedtest }
        '8' { Send-WOL }
        '9' { Repair-Network }
        '0' { Export-DiagnosticBundle }
        'Q' { break }
        default { Write-Host "  [?] Invalid selection." -ForegroundColor DarkYellow }
    }

    if ($choice -ne 'Q') { Pause-Return }

} while ($choice -ne 'Q')

Write-Host "`n  Session Terminated.`n" -ForegroundColor DarkGray
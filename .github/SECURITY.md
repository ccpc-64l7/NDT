# Security Policy & Responsible Disclosure

First off, thank you! This is an open-source project, and we absolutely welcome anyone and everyone to help out. Because the Network Diagnostics Toolkit (NDT) interacts with deep system architecture and network routing, security is our highest priority. 

We are incredibly grateful to community members and security researchers who help keep this project safe, reliable, and ethically sound.

## Supported Versions

Currently, NDT is in active Beta development. We only provide security patches for the most recent releases. If you are auditing or testing the project, please ensure you are on the latest build:

| Version | Supported          |
| ------- | ------------------ |
| Beta 000.17x | :white_check_mark: |
| < Beta 000.170 | :x:                |

*Note: Security guarantees apply only when running NDT on supported environments (PowerShell 7+ and actively maintained Python 3.x releases).*

## Responsible Disclosure Policy

Because NDT possesses administrative capabilities and handles diagnostic telemetry, **please do not report critical security vulnerabilities via public GitHub issues.** We require time to triage and patch vulnerabilities before they can be weaponized against users' networks or legacy systems.

If you discover a security flaw, privilege escalation bug, or data privacy leak, please follow our responsible disclosure process:

1. **Private Contact:** Email a summary of the vulnerability directly to **NDTsoftware@ccpcrepair.com**.
2. **Sanitize Your Proof:** Include details on how to reproduce the bug and the environment variables. If you are attaching logs or Proof-of-Concept (PoC) code, **you must ensure all PII, external IP addresses, and sensitive network data are sanitized.**
3. **Triage & Remediation:** We will acknowledge your report promptly. If you have a patch in mind, let us know in the email, and we can coordinate a private repository fix.

In alignment with our professional ethics and Google Open Source standards, once the vulnerability is safely patched and deployed, we will gladly give you full credit for the discovery in our official release notes and security advisories!
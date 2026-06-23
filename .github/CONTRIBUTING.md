# Contributing to NDT & OSINT-Labs

Welcome! We are thrilled that you're here. This project relies on the open-source community, and **anyone** is welcome to help out, regardless of your experience level. 

Because the Network Diagnostics Toolkit (NDT) interacts with core network routing, OSINT data, and system-level diagnostics, we hold our contributors to a high standard of professional ethics. 

## Our Guiding Principles
In alignment with Google Open Source Community Guidelines, all contributions must reflect the following:
* **Respect the User:** Code must not introduce undocumented tracking, telemetry, or vulnerabilities.
* **Respect the Opportunity:** Treat this repository as a professional learning environment. We are here to build secure, reliable infrastructure.
* **Respect Each Other:** Adhere strictly to our [Code of Conduct](CODE_OF_CONDUCT.md). Ensure communication in PRs and Issues remains constructive and kind.

## Pre-Flight Ethics & Data Privacy
Before contributing code or opening an issue, you must ensure that **no sensitive data is exposed**. 
* **Sanitize all logs:** Never commit real, identifiable public IP addresses, MAC addresses, API keys, or personal credentials.
* **Test responsibly:** Use internal homelab IP ranges (e.g., `192.168.x.x`, `10.x.x.x`) or documented test networks when providing examples.

## How You Can Help
You don't just have to write code to contribute! We welcome help with:
*   **Bug Reports:** Did something break? Open an issue using our Bug Report template and let us know (remember to sanitize your logs!).
*   **Feature Requests:** Have a cool idea for a new Python OSINT module or a PowerShell network fix? Open an issue so we can discuss the architecture.
*   **Documentation:** Notice a typo, missing comments, or a confusing instruction? Documentation is just as important as code. Feel free to fix it.
*   **Code Contributions:** Grab an open issue, write some code, and submit a Pull Request (PR). 
    * *Note on Architecture:* The main CLI interface lives in `NDT.ps1`. Python helpers and OSINT modules should be placed in the `scripts/` directory.

## Submitting a Pull Request
1. Fork the repository and create your feature branch (e.g., `feature/dns-resolver-update`).
2. Make your changes and test them locally in a safe environment.
3. Perform a self-audit: Ensure no `.zip` diagnostic bundles, `.log` files, or API keys are accidentally staged in your commit.
4. Submit a Pull Request using the provided PR template. Include a brief description of what you changed, why it is necessary, and how it was tested.

Don't worry about your code being perfect on the first try. We review PRs collaboratively and are here to learn together. Thank you for helping make this project more secure and efficient!
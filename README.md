# CPE211-SSH-LOGIN-AUTHENTICATION-ANTI-BRUTEFORCE-

How to use:
Ensure all bash scripts are within the same directory. 
Master control script is master_security.sh and MUST be used with ROOT privileges.

# SSH Anti-Bruteforce Security Management Suite

A modular, Bash-based security framework designed to harden SSH access on Debian and Ubuntu Linux servers by preventing brute force attacks. This suite automates the deployment of intrusion prevention systems, local account lockout policies, and inactive session timeouts, while providing tools for manual firewall auditing.

## System Requirements

* **Operating System**: Debian or Ubuntu-based distributions (requires the `apt` package manager and standard `/var/log/auth.log` logging).
* **Privileges**: Root or `sudo` access is strictly required for all modules.
* **Dependencies**: Standard GNU core utilities, `iptables`, `systemd`, and `pam` modules.

## Installation and Setup

1.  **Transfer the Scripts**: Ensure all `.sh` files are located in the same directory on the target server.
2.  **Grant Execution Permissions**: Make all scripts executable by running the following command in the terminal:
    ```bash
    chmod +x *.sh
    ```
3.  **Launch the Control Panel**: Start the system by executing the master script with root privileges:
    ```bash
    sudo bash master_security.sh
    ```

## Module Overview

The suite operates through a central interactive menu. 

1.  **Configure Fail2Ban**: Installs Fail2Ban and provisions an isolated configuration file (`/etc/fail2ban/jail.d/custom_sshd.local`) to permanently drop traffic from IPs with 5 failed login attempts.
2.  **Set Idle Timeout**: Configures `/etc/ssh/sshd_config` to automatically terminate user sessions after 10 minutes of inactivity.
3.  **Run IP Blacklist System**: A manual auditing tool that parses log files and drops abusive IPs using `iptables`.
4.  **Configure Account Lockout**: Modifies Pluggable Authentication Modules (PAM) to lock local user accounts for 10 minutes after 3 consecutive failed attempts.
5.  **Manage IP Whitelist**: Inserts high-priority `ACCEPT` rules into `iptables` and excludes trusted IPs from Fail2Ban.
6.  **View Security Logs**: Parses and displays recent failed attempts, successful logins, and top attacking IPs.
7.  **View SSH Monitoring Report**: Generates a comprehensive summary of total attacks and cross-references blocked IPs.
8.  **Full Security Deployment**: Automates the sequential execution of Fail2Ban, Idle Timeout, and Account Lockout configurations.

---

## Brute Force Simulation Guide

To safely test the effectiveness of the security suite, you will need two separate Linux machines or virtual machines residing on the same network subnet. 

### Phase 1: Defender Preparation (Machine A)

This is the server hosting the SSH service and the security scripts.

1.  **Create a Target Account**: Create a standard user account specifically for this simulation.
    ```bash
    sudo adduser testuser
    ```
2.  **Identify the Target IP**: Record the IP address assigned to this machine's active network interface.
    ```bash
    ip a or ifconfig
    ```
3.  **Deploy Defenses**: Launch the master script and select Option 8 to run the full automated security deployment.
    ```bash
    sudo bash master_security.sh
    ```

### Phase 2: Attack Execution (Machine B)

This is the secondary machine acting as the attacker.

1.  **Verify Connectivity**: Ensure Machine B can communicate with Machine A.
    ```bash
    ping -c 4 [IP_of_Machine_A]
    ```
2.  **Execute the Attack Loop**: Run the following Bash loop in the terminal to rapidly generate connection attempts. Replace the bracketed text with the IP address of Machine A.
    ```bash
    for i in {1..7}; do
        echo "Attempt $i"
        ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no testuser@[IP_of_Machine_A]
    done
    ```
3.  **Provide False Credentials**: The terminal will prompt you for a password. Type an incorrect password and press Enter. Repeat this process for every prompt.
    * *Note*: The terminal will freeze after the 5th failed attempt. This indicates the firewall has successfully dropped the connection.

### Phase 3: Defense Verification (Machine A)

Return to the defending machine to confirm the attack was neutralized.

1.  **Verify Local Account Lockout**: Check if the PAM module successfully locked the target user account.
    ```bash
    sudo faillock --user testuser
    ```
2.  **Verify Network Mitigation**: Check if Fail2Ban successfully banned the IP address of Machine B.
    ```bash
    sudo fail2ban-client status sshd
    ```
3.  **Review System Logs**: Generate a final report to view the logged attack data.
    ```bash
    sudo bash monitor.sh
    ```

## Credits and Authors

* **Pios, Joshua Paul B.** : Project Leader and System Architect
* **Dueñas, Ranzel Aldous Gabriel L.** : Developer and Debugger
* **Masongsong, John Marvin B.** : Developer and Tester
* **Momo, Borge Rudolf A.** : Developer, Tester, and Debugger
* **Santiago, David Owen A.** : Primary Developer and System Architect

This project was developed for CPE211 AY 2025-2026.
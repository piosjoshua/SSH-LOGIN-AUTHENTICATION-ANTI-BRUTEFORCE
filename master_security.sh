#!/bin/bash
# master_security.sh
# Centralized management script for the SSH security module suite.

# 1. Verify root privileges
if [[ $EUID -ne 0 ]]; then
    echo "Error: This master script must be run as root or with sudo."
    exit 1
fi

# 2. Dynamically determine the directory where the scripts are stored
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# 3. Define the menu interface
show_menu() {
    echo ""
    echo "=========================================="
    echo "      SSH Security Management System      "
    echo "=========================================="
    echo "1) Configure Fail2Ban (configurefail2ban.sh)"
    echo "2) Set Idle Timeout (idletest.sh)"
    echo "3) Run IP Blacklist System (ipblacklistsystem.sh)"
    echo "4) Configure Account Lockout (locktest.sh)"
    echo "5) Manage IP Whitelist (whitelist.sh)"
    echo "6) View Security Logs (verbose.sh)"
    echo "7) View SSH Monitoring Report (monitor.sh)"
    echo "8) Full Security Deployment (Run All)"
    echo "9) Exit"
    echo "=========================================="
}

# 4. Define the execution function
run_script() {
    local script_name="$1"
    local script_path="${SCRIPT_DIR}/${script_name}"

    if [[ -f "$script_path" ]]; then
        echo ""
        echo ">>> Executing ${script_name}..."
        # Execute the script in a subshell
        bash "$script_path"
        echo ">>> Finished ${script_name}."
    else
        echo ""
        echo "Error: ${script_name} not found in ${SCRIPT_DIR}."
        echo "Please ensure all scripts are in the same directory."
    fi
}

# 5. Execute the main loop
while true; do
    show_menu
    read -p "Select an option [1 to 9]: " choice
    
    case $choice in
        1) run_script "configurefail2ban.sh" ;;
        2) run_script "idletest.sh" ;;
        3) run_script "ipblacklistsystem.sh" ;;
        4) run_script "locktest.sh" ;;
        5) run_script "whitelist.sh" ;;
        6) run_script "verbose.sh" ;;
        7) run_script "monitor.sh" ;;
        8)
           echo "Initiating full security deployment..."
           run_script "configurefail2ban.sh"
           run_script "idletest.sh"
           run_script "locktest.sh"
           #run_script "ipblacklistsystem.sh"
           #run_script "whitelist.sh"
           run_script "verbose.sh"
           run_script "monitor.sh"
           echo "Full deployment complete."
           ;;
        9) 
           echo "Exiting the Security Management System."
           exit 0 
           ;;
        *) 
           echo "Invalid option. Please enter a number between 1 and 9." 
           ;;
    esac
done
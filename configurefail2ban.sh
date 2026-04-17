#!/bin/bash
# configurefail2ban.sh

# Ensuring script is run with root privileges. 
[[ $EUID -ne 0 ]] && echo "Run as root." && exit 1

# PART 1: checking if fail2ban is installed and active. 
# If it is not installed, the script updates the package list and installs fail2ban using apt. 
# If fail2ban is already installed, it simply informs the user.

# check if fail2ban is installed
if [ -z "$(command -v fail2ban-client)" ]; then
    echo "Fail2ban is not installed. Installing..."
    apt update && apt install -y fail2ban
else
    echo "Fail2ban is already installed."
fi

# check if fail2ban is active and running
if systemctl is-active --quiet fail2ban; then
    echo "Fail2ban is active and running."
else
    echo "Fail2ban is not active. Starting and enabling..."
    systemctl enable --now fail2ban
    echo "Fail2ban has been started and enabled."
fi

# PART 2: Configuring fail2ban to protect SSH.
# dedicated, isolated drop-in configuration file within the /etc/fail2ban/jail.d/ directory. 
# Fail2ban automatically reads files in this directory, allowing modular configuration without 
# interfering with other services.

JAIL_DIR="/etc/fail2ban/jail.d"
CUSTOM_CONF="$JAIL_DIR/custom_sshd.local"
echo "Configuring Fail2ban to protect SSH safely..."
 
# Ensure directory exists and write to an isolated modular file
mkdir -p "$JAIL_DIR"
cat <<EOF > "$CUSTOM_CONF"
[DEFAULT]
ignoreip = 127.0.0.1/8 ::1

[sshd]
enabled = true


port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 5
bantime = 600
findtime = 600
EOF

# restart fail2ban to apply changes
systemctl restart fail2ban
echo "Fail2ban configuration applied successfully."
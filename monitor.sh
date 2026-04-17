#!/bin/bash

# Verify root privileges
if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root or with sudo."
    exit 1
fi

LOG_FILE="/var/log/auth.log"
BLACKLIST="/etc/ssh/ip_blacklist.txt"
WHITELIST="/etc/ssh/ip_whitelist.txt"

echo "SSH SECURITY MONITORING REPORT"

# SUMMARY
echo ""
echo "SUMMARY"
echo "Total Failed Attempts: $(grep -a -c 'Failed password' $LOG_FILE 2>/dev/null)"
echo "Total Invalid Users: $(grep -a -c 'Invalid user' $LOG_FILE 2>/dev/null)"

# FAILED LOGIN ATTEMPTS
echo ""
echo "FAILED LOGIN ATTEMPTS PER IP"

FAILED=$(grep -a "Failed password" $LOG_FILE 2>/dev/null)

if [ -z "$FAILED" ]; then
    echo "No failed login attempts found."
else
    echo "$FAILED" | grep -oP 'from \K[\d.]+' | sort | uniq -c | sort -nr | while read -r count ip
    do
        status=""

        # Whitelist overrides block
        if grep -qx "$ip" "$WHITELIST" 2>/dev/null; then
            status="[WHITELISTED]"
        elif grep -qx "$ip" "$BLACKLIST" 2>/dev/null; then
            status="[BLOCKED]"
        fi

        echo "$count $ip $status"
    done
fi

# INVALID USERS
echo ""
echo "INVALID USER ATTEMPTS"
grep -a "Invalid user" $LOG_FILE 2>/dev/null || echo "No invalid user attempts found."

# BLOCKED IPS
echo ""
echo "BLOCKED IPS"
if [ -f "$BLACKLIST" ] && [ -s "$BLACKLIST" ]; then
    cat "$BLACKLIST"
else
    echo "No blocked IPs."
fi

# WHITELISTED IPS
echo ""
echo "WHITELISTED IPS"
if [ -f "$WHITELIST" ] && [ -s "$WHITELIST" ]; then
    cat "$WHITELIST"
else
    echo "No whitelisted IPs."
fi

# FAIL2BAN STATUS
echo ""
echo "FAIL2BAN STATUS"
fail2ban-client status sshd 2>/dev/null || echo "Fail2Ban not running or not configured."

# HISTORICAL TRENDS (LAST 7 DAYS)
echo ""
echo ""
echo "Date       Time     IP Address        Status"
grep "Ban" /var/log/fail2ban.log
echo ""
echo "END OF REPORT"

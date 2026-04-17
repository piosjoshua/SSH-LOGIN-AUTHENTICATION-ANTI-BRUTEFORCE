#!/bin/bash

# 1. Verify root privileges
[[ $EUID -ne 0 ]] && echo "Run as root." && exit 1

WHITELIST_FILE="/etc/ssh/ip_whitelist.txt"
BLACKLIST_FILE="/etc/ssh/ip_blacklist.txt"

init_file() {
    [ ! -f "$WHITELIST_FILE" ] && touch "$WHITELIST_FILE"
    chmod 600 "$WHITELIST_FILE"
}

remove_from_blacklist() {
    local ip=$1
    sed -i "/^$ip$/d" "$BLACKLIST_FILE" 2>/dev/null
    iptables -D INPUT -s "$ip" -j DROP 2>/dev/null

    echo "Removed $ip from blacklist, if existed."
}

add_ip() {
    read -p "Enter IP to whitelist: " ip

    remove_from_blacklist "$ip"

    if ! grep -qx "$ip" "$WHITELIST_FILE"; then
        echo "$ip" >> "$WHITELIST_FILE"
        iptables -I INPUT 1 -s "$ip" -j ACCEPT
        echo "Whitelisted: $ip"

        # Add to Fail2ban ignoreip if configured 
        JAIL_LOCAL="/etc/fail2ban/jail.d/custom_sshd.local"
         if [[ -f "$JAIL_LOCAL" ]]; then
             if ! grep -q "^ignoreip .*$ip" "$JAIL_LOCAL"; then
                 sed -i "/^ignoreip/ s/$/ $ip/" "$JAIL_LOCAL"
                 systemctl restart fail2ban
                 echo "Added to Fail2ban ignoreip list."
             fi
         fi
         
    else
        echo "Already whitelisted."
    fi
}

remove_ip() {
    read -p "Enter IP to remove: " ip
    sed -i "/^$ip$/d" "$WHITELIST_FILE"
    iptables -D INPUT -s "$ip" -j ACCEPT 2>/dev/null

    # Remove from Fail2ban ignoreip if configured
    JAIL_LOCAL="/etc/fail2ban/jail.d/custom_sshd.local"
    if [[ -f "$JAIL_LOCAL" ]]; then
        # Removes the specific IP and any trailing space
        sed -i "/^ignoreip/ s/ $ip//g" "$JAIL_LOCAL"
        systemctl restart fail2ban
        echo "Removed from Fail2ban ignoreip list."
    fi
    echo "Removed: $ip"
}

view_ips() {
    echo "=== Whitelist ==="
    cat "$WHITELIST_FILE"
}

init_file

while true; do
    echo ""
    echo "=== UBUNTU WHITELIST MENU ==="
    echo "1. Add IP"
    echo "2. Remove IP"
    echo "3. View"
    echo "4. Exit"
    read -p "Choose: " c

    case $c in
        1) add_ip ;;
        2) remove_ip ;;
        3) view_ips ;;
        4) exit ;;
    esac
done


#!/bin/bash

# REQUIREMENTS TO RUN THIS SCRIPT:
# 1. Must be on a Debian/Ubuntu based system (Ubuntu, Mint, Kali)
#    - auth.log does not exist on RHEL/CentOS/Fedora
# 2. Must be run as root or with sudo: sudo bash verbose.sh
# 3. /var/log/auth.log must exist and have content
# 4. Required commands: grep, awk, sort, uniq, tail, who

[[ $EUID -ne 0 ]] && echo "Run as root." && exit 1

AUTH_LOG="/var/log/auth.log"

echo "=== FAILED LOGINS ==="
grep -i "failed\|invalid user" "$AUTH_LOG" 2>/dev/null \
  | awk '{
      for(i=1;i<=NF;i++) {
          if ($i == "from") { ip=$(i+1); break; }
      }
      print $1, $2, $3, "IP:", (ip ? ip : "Unknown")
  }' | tail -n 10 \
  || echo "None found."

echo ""
# Searches for successful logins with the keyword "accepted"
echo "=== SUCCESSFUL LOGINS ==="
grep -i "accepted" "$AUTH_LOG" 2>/dev/null \
  | awk '{
      for(i=1;i<=NF;i++) {
          if ($i == "from") { ip=$(i+1); break; }
      }
      print $1, $2, $3, "IP:", (ip ? ip : "Unknown")
  }' | tail -n 10 \
  || echo "None found."

echo ""
# requires grep -P (Perl regex)
echo "=== TOP ATTACKING IPs ==="
grep -i "failed\|invalid user" "$AUTH_LOG" 2>/dev/null \
  | grep -oP 'from \K[\d.]+' \
  | sort | uniq -c | sort -rn | head -n 5 \
  | awk '{print $2, "-", $1, "attempts"}' \
  || echo "None found."

echo ""
# requires the who command
echo "=== CURRENTLY LOGGED IN ==="
who -u | awk '{print $1, $2, $3, $4, "PID:", $6}' \
  || echo "No active sessions."

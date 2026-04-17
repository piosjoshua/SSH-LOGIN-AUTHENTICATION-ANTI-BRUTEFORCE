#!/bin/bash
# Purpose: Lock user accounts after multiple failed SSH login attempts

[[ $EUID -ne 0 ]] && echo "Run as root." && exit 1

FAIL_LIMIT=3
LOCK_TIME=600
PAM_FILE="/etc/pam.d/sshd"

# Backup PAM config
cp "$PAM_FILE" "${PAM_FILE}.bak"

# Remove existing faillock entries to prevent duplicates
sed -i '/pam_faillock.so/d' "$PAM_FILE"
 
# Insert PAM rules right after the first line safely
sed -i "1 a auth required pam_faillock.so preauth silent deny=$FAIL_LIMIT unlock_time=$LOCK_TIME\nauth [default=die] pam_faillock.so authfail deny=$FAIL_LIMIT unlock_time=$LOCK_TIME\naccount required pam_faillock.so" "$PAM_FILE"

echo "Accounts will be locked after $FAIL_LIMIT failed attempts for $LOCK_TIME seconds."

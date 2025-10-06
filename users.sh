#!/bin/bash

# create_users.sh: Automate user creation, group assignment, secure password generation, and logging.
# Usage: sudo bash create_users.sh <input_file>
# See accompanying technical article for full explanation.

# Log file and secure password storage
LOG_FILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.csv"

log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $*" >> "$LOG_FILE"
}

generate_password() {
    # 14-character random password, alphanum
    tr -dc 'A-Za-z0-9' </dev/urandom | head -c 14
}

# Ensure /var/secure exists with strict permissions
if [ ! -d /var/secure ]; then
    mkdir -p /var/secure
    chmod 700 /var/secure
    log_action "Created /var/secure"
fi

touch "$LOG_FILE"
touch "$PASSWORD_FILE"
chmod 600 "$LOG_FILE" "$PASSWORD_FILE"

if [ "$(id -u)" -ne 0 ]; then
    echo "Script must be run as root." >&2
    exit 1
fi

INPUT="$1"
if [ ! -f "$INPUT" ]; then
    echo "Input file not found: $INPUT" >&2
    exit 1
fi

while IFS=';' read -r rawuser rawgroups; do
    # Ignore empty lines/comments
    [[ -z "$rawuser" || "$rawuser" = \#* ]] && continue
    user=$(echo "$rawuser" | xargs)
    [ -z "$user" ] && continue

    # Parse group list, trim whitespace
    groups=$(echo "$rawgroups" | tr ',' '\n' | xargs | tr ' ' ',' | sed 's/,,*/,/g')
    # Ensure the user's personal group exists
    if ! getent group "$user" >/dev/null; then
        groupadd "$user"
        log_action "Created group $user"
    fi

    # Create any additional groups
    for group in $(echo "$groups" | tr ',' ' '); do
        if ! getent group "$group" >/dev/null 2>&1; then
            groupadd "$group"
            log_action "Created group $group"
        fi
    done

    if id "$user" &>/dev/null; then
        log_action "User $user already exists"
        continue
    fi

    # Create user (with home dir, default shell, personal group)
    useradd -m -g "$user" -s /bin/bash "$user"
    if [ $? -ne 0 ]; then
        log_action "Failed to create user $user"
        continue
    fi

    # Add user to additional groups if defined
    if [ -n "$groups" ]; then
        usermod -aG "$groups" "$user"
        log_action "Added $user to groups: $groups"
    fi

    # Set home dir ownership/permissions
    chmod 700 /home/"$user"
    chown "$user":"$user" /home/"$user"
    log_action "Set permissions for /home/$user"

    # Generate and set password
    passwd=$(generate_password)
    echo "$user:$passwd" | chpasswd
    log_action "Password set for $user"
    echo "$user,$passwd" >> "$PASSWORD_FILE"

done < "$INPUT"

chmod 600 "$PASSWORD_FILE"
log_action "Script completed"

echo "User creation complete. Log: $LOG_FILE. Passwords: $PASSWORD_FILE"


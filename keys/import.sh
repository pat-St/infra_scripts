#!/bin/env bash
## Prepare env.
TARGET_PATH=~/.ssh
mkdir -p "$TARGET_PATH"
cp keys/config "${TARGET_PATH}/config"
chmod 600 "${TARGET_PATH}/config"

# names=( proxmox wireguard pihole monitor docker certmanager )
## Import hostname from config
names=( $( grep -E '^Host\s{1}\w+$' config | sed -E 's/Host\s{1}//' | sed -z 's/\n/ /g' ) )

for name in "${names[@]}"
do
    # Generated key pair
    file_name="id_ed25519_$name"
    file_path="$TARGET_PATH/$file_name"
    key_var="PRIV_KEY_${name}"
    touch "$file_path"
    echo -e "${!key_var}" | tr -d '\r' > "$file_path"
    chmod 600 "$file_path"
done

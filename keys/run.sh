#!/bin/env bash
names=( proxmox wireguard pihole monitor docker )
for name in "${names[@]}"
do
    # Generate key pair
    file_name="id_ed25519_$name"
    [[ ! -f "$file_name" ]] && ssh-keygen -f "$file_name" -t ed25519 -N ""
    # test connection
    ssh -F config -q -i "$file_name" "$name" exit
    exit_code="$?"
    # upload key to target
    [[ "$exit_code" -ne 0 ]] && ssh-copy-id -i "$file_name" "$name"
done

#!/bin/env bash
echo $1
chain=$( cat ${1}fullchain.pem )
key=$( cat ${1}privkey.pem )

pvesh create /nodes/proxmox2/certificates/custom --certificates "$chain" --key "$key" --force 1 --restart 1

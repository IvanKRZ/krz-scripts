#!/usr/bin/env bash

# Author: Ivan Krznaric-Bertic, November 2026
# Purpose: Idempotent script that creates a Terraform service account and grants it
#          the permissions it needs. Run as root on the Proxmox host.

# --- CONFIGURATION: ADJUST HERE ---
USERNAME=""
POOLNAME=""
ROLENAME=""
TOKENNAME=""
BRIDGE="vmbr0"
TEMPLATE_ID="9000"
STORAGE="local-lvm"
# --- END OF CONFIGURATION ---

# CONFIGURATION AND ENVIRONMENT CHECKS

# Check: running on a Proxmox host
if ! command -v pveum > /dev/null 2>&1; then
    echo "Fehler: pveum nicht gefunden. Das Script muss auf einem Proxmox-Host laufen." >&2
    exit 1
fi

# Check: running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Fehler: Script muss als Root laufen." >&2
    exit 1
fi

# Check: all settings are filled in
for name in USERNAME POOLNAME ROLENAME TOKENNAME BRIDGE TEMPLATE_ID STORAGE; do
    if [ -z "${!name}" ]; then
        echo "Fehler: $name ist nicht gesetzt. Bitte die Konfiguration oben im Skript ausfüllen." >&2
        exit 1
    fi
done

USERID="$USERNAME@pve"
PRIVS="VM.Allocate,VM.Audit,VM.Clone,VM.Config.CDROM,VM.Config.CPU,VM.Config.Cloudinit,VM.Config.Disk,VM.Config.HWType,VM.Config.Memory,VM.Config.Network,VM.Config.Options,VM.GuestAgent.Audit,Pool.Audit,VM.PowerMgmt"

# Create the pool
if ! pvesh get /pools/"$POOLNAME" > /dev/null 2>&1; then
    pveum pool add "$POOLNAME" --comment "Von Terraform verwalteter VM Pool"
    echo "Pool - $POOLNAME - angelegt."
else
    echo "Pool - $POOLNAME - bereits vorhanden!"
fi

# Create the role, or update its privileges if it already exists
if ! pvesh get /access/roles/"$ROLENAME" > /dev/null 2>&1; then
    pveum role add "$ROLENAME" --privs "$PRIVS"
    echo "Rolle - $ROLENAME - angelegt"
else
    pveum role modify "$ROLENAME" --privs "$PRIVS"
    echo "Rolle - $ROLENAME - angepasst"
fi

# Create the service account (no password)
if ! pvesh get /access/users/"$USERID" > /dev/null 2>&1; then
    pveum user add "$USERID" --comment "Dienstkonto für Terraform"
    echo "Benutzerkonto - $USERID - angelegt."
else
    echo "Benutzerkonto - $USERID - bereits vorhanden!"
fi

# Set the service account's permissions (safe to repeat, existing ACLs are overwritten)
pveum acl modify /pool/"$POOLNAME" --users "$USERID" --roles "$ROLENAME"
pveum acl modify "/vms/$TEMPLATE_ID" --users "$USERID" --roles PVETemplateUser
pveum acl modify "/storage/$STORAGE" --users "$USERID" --roles PVEDatastoreUser
pveum acl modify /sdn/zones/localnetwork/"$BRIDGE" --users "$USERID" --roles PVESDNUser
echo "ACLs für Benutzer - $USERID - gesetzt"

# Add an API token for the service account and display it (shown only once)
if ! pvesh get /access/users/"$USERID"/token/"$TOKENNAME" > /dev/null 2>&1; then
    echo "ACHTUNG! DER TOKEN WIRD NUR EINMALIG ANGEZEIGT! UNBEDINGT SICHERN!"    
    pveum user token add "$USERID" "$TOKENNAME" --privsep 0 --output-format json
    echo "Token angelegt"
else
    echo "Token bereits vorhanden!"
fi

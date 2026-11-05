# Proxmox / IaC

[English](#english) | [Deutsch](#deutsch)

---

## English

Scripts that prepare a Proxmox VE host for Infrastructure as Code (IaC) tools such as
Terraform.

### `Terraform/create-terraform-account.sh`

Creates a dedicated service account for Terraform that has only the permissions it needs,
so no administrator account is required.

What the script sets up:

1. A resource pool for the VMs that Terraform manages.
2. A role with the privileges needed to clone and configure VMs.
3. A user in the `pve` realm (service account, no password).
4. Four permissions (ACLs), each with minimal rights:
   - the pool (create and configure VMs),
   - the template VM (clone only),
   - the storage (allocate disks),
   - the network bridge (attach network cards).
5. An API token for the user.

The script is safe to run repeatedly. Existing objects are kept, the role's privileges
and the permissions are set again, and no second token is created.

#### Usage

1. Copy the script to the Proxmox host.
2. Open it and fill in the configuration block at the top: `USERNAME`, `POOLNAME`,
   `ROLENAME` and `TOKENNAME`. `BRIDGE`, `TEMPLATE_ID` and `STORAGE` come with defaults
   that you can change.
3. Run it as `root` on the Proxmox host:
   ```bash
   bash create-terraform-account.sh
   ```

Before it changes anything, the script checks that it runs on a Proxmox host, as `root`,
and that no setting is empty. Otherwise it stops with an error message.

**The API token is displayed only once, at the end of the first run.** Store it safely
right away. If you lose it, delete it with `pveum user token remove <user>@pve <tokenname>`
and run the script again.

---

## Deutsch

Skripte, die einen Proxmox-VE-Host für Werkzeuge der Infrastructure as Code (IaC) wie
Terraform vorbereiten.

### `Terraform/create-terraform-account.sh`

Legt ein eigenes Dienstkonto für Terraform an, das nur die Rechte hat, die es braucht.
Ein Administratorkonto ist dafür nicht nötig.

Was das Skript einrichtet:

1. Einen Ressourcen-Pool für die VMs, die Terraform verwaltet.
2. Eine Rolle mit den Rechten, die zum Klonen und Konfigurieren von VMs nötig sind.
3. Einen Benutzer im Realm `pve` (Dienstkonto, ohne Passwort).
4. Vier Berechtigungen (ACLs), jeweils mit minimalen Rechten:
   - auf den Pool (VMs anlegen und konfigurieren),
   - auf die Template-VM (nur klonen),
   - auf den Speicher (Platten belegen),
   - auf die Netzwerk-Bridge (Netzkarten anschließen).
5. Einen API-Token für den Benutzer.

Das Skript kann bedenkenlos mehrfach ausgeführt werden. Bestehende Objekte bleiben
erhalten, die Rechte der Rolle und die Berechtigungen werden erneut gesetzt, und es
entsteht kein zweiter Token.

#### Benutzung

1. Das Skript auf den Proxmox-Host kopieren.
2. Es öffnen und den Konfigurationsblock oben ausfüllen: `USERNAME`, `POOLNAME`,
   `ROLENAME` und `TOKENNAME`. `BRIDGE`, `TEMPLATE_ID` und `STORAGE` haben Standardwerte,
   die du ändern kannst.
3. Als `root` auf dem Proxmox-Host ausführen:
   ```bash
   bash create-terraform-account.sh
   ```

Bevor es etwas ändert, prüft das Skript, ob es auf einem Proxmox-Host als `root` läuft
und ob keine Einstellung leer ist. Andernfalls bricht es mit einer Fehlermeldung ab.

**Der API-Token wird nur einmal angezeigt, am Ende des ersten Laufs.** Sichere ihn sofort.
Geht er verloren, löschst du ihn mit `pveum user token remove <benutzer>@pve <tokenname>`
und startest das Skript erneut.

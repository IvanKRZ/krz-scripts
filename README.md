# krz-scripts

[English](#english) | [Deutsch](#deutsch)

---

## English

A personal collection of scripts I have written for my own projects and reuse
regularly. It is still small and will grow over time.

Rules for everything in this repository:

- Scripts are meant to be reusable. Anything that depends on your setup is a variable at
  the top of the script.
- Nothing secret or internal is stored here: no passwords, tokens or internal addresses.
- Scripts are provided as is (see [LICENSE](LICENSE)). Read a script and try it in a safe
  environment before you run it on a system that matters.

### Structure

```
krz-scripts/
├── LICENSE
├── README.md
└── Proxmox/
    └── IaC/
        ├── README.md
        └── Terraform/
            └── create-terraform-account.sh
```

| Folder | Content |
|---|---|
| [`Proxmox/`](Proxmox/) | Scripts for Proxmox VE hosts |
| [`Proxmox/IaC/`](Proxmox/IaC/) | Infrastructure as Code: preparing a Proxmox host for automation tools such as Terraform |

Each area has its own README with details.

---

## Deutsch

Eine Sammlung von Skripten, die ich für meine eigenen Projekte geschrieben habe und
regelmäßig wiederverwende. Sie ist noch klein und wächst mit der Zeit.

Regeln für alles in diesem Repository:

- Die Skripte sind wiederverwendbar gedacht. Alles, was von deiner Umgebung abhängt, steht
  als Variable oben im Skript.
- Hier liegt nichts Geheimes oder Internes: keine Passwörter, Tokens oder internen
  Adressen.
- Die Skripte werden ohne Gewähr bereitgestellt (siehe [LICENSE](LICENSE)). Lies ein
  Skript und probiere es in einer sicheren Umgebung aus, bevor du es auf einem wichtigen
  System ausführst.

### Aufbau

```
krz-scripts/
├── LICENSE
├── README.md
└── Proxmox/
    └── IaC/
        ├── README.md
        └── Terraform/
            └── create-terraform-account.sh
```

| Ordner | Inhalt |
|---|---|
| [`Proxmox/`](Proxmox/) | Skripte für Proxmox-VE-Hosts |
| [`Proxmox/IaC/`](Proxmox/IaC/) | Infrastructure as Code: einen Proxmox-Host für Automatisierungswerkzeuge wie Terraform vorbereiten |

Jeder Bereich hat ein eigenes README mit Details.

# Simple service update script #

## Prepared infrastructure ##

- 2 Proxmox nodes.
- LXC Container as services.
- Services based on Debian >=10.
- Services accessible over SSH public key authentication

## Setup ##

```sh
python -m venv .venv
```

```sh
source .venv/bin/activate && \
pip install -r requirements.txt && \
source .venv/bin/activate && \
ansible-galaxy collection install -r requirements.yaml
```

## Usage ##

```sh
source .venv/bin/activate && \
ansible-playbook ansible-playbook update_infra.yaml
```

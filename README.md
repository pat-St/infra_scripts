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
ansible-galaxy collection install -r collections/requirements.yaml
```

## Usage ##

```sh
source .venv/bin/activate && \
ansible-playbook ansible-playbook update_infra.yaml
```

## Add a new target for ansible cron job

1. Added a new Entry under `keys/config`.
2. Added a new Entry under `.gitea/workflows/update_infra_workfow.yml` with New environment Entry scheme: `PRIV_KEY_$$host-name$$: ${{ secrets.PRIV_KEY_$$host-name$$ }}`.

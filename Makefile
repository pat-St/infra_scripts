.PHONY: run/update_infra run/update_certs run/validate

INSTALLED=.venv/installed

install: $(INSTALLED)

.venv/installed: requirements.txt collections/requirements.yaml
	python -m venv .venv
	source .venv/bin/activate ; \
		pip install -Ur requirements.txt \
		&& pip install --upgrade pip \
		&& ansible-galaxy collection install -r collections/requirements.yaml
	touch .venv/installed

run/update_infra: $(INSTALLED)
	source .venv/bin/activate ; ansible-playbook -v update_infra.yaml

run/update_certs: $(INSTALLED)
	source .venv/bin/activate ; ansible-playbook -v update_certs.yaml

run/validate: $(INSTALLED)
	source .venv/bin/activate ; ansible-lint

clean: .venv
	rm -rf .venv

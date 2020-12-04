USERNAME := $(shell whoami)
PRIVATE_KEY_PATH := ~/.ssh/rpi/gh_rpi

image:
	# Ensure sudo does not require password during playbok run for localhost
	@sudo ls > /dev/null
	ansible-playbook \
		--user ${USERNAME} \
		--inventory inventory/hosts.yaml \
		playbooks/imager.yaml

wifi:
	ansible-playbook \
		--user pi \
		--inventory inventory/hosts.yaml \
		--private-key ${PRIVATE_KEY_PATH} \
		playbooks/wifi.yaml

.PHONY: k3s-ansible
.ONESHELL:
k3s-ansible:
	git clone \
		git@github.com:rancher/k3s-ansible.git \
		k3s-tmp

	ansible-playbook \
		--user pi \
		--inventory k3s-ansible/hosts.ini \
		--private-key ${PRIVATE_KEY_PATH} \
		k3s-tmp/site.yml

	scp pi3:~/.kube/config ~/.kube/config_temp
	sed -i -e "s/default/pik3s/g" ~/.kube/config_temp
	if [ -f ~/.kube/config ]; then
		cp ~/.kube/config ~/.kube/config.bak
	fi
	cat ~/.kube/config_temp >> ~/.kube/config
	rm ~/.kube/config_temp
	chmod 0600 ~/.kube/config
	rm -rf k3s-tmp

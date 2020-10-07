USERNAME := $(shell whoami)
PRIVATE_KEY_PATH := ~/.ssh/rpi/gh_rpi

image:
	# Ensure sudo does not require password during playbok run for localhost
	@sudo ls > /dev/null
	ansible-playbook -u ${USERNAME} -i inventory/inventory playbooks/imager.yaml

wifi:
	ansible-playbook -u pi -i inventory/inventory playbooks/wifi.yaml --private-key ${PRIVATE_KEY_PATH}

k3s-ansible:
	echo "Ensure you have pulled down k3s-ansible repo"
	ansible-playbook -u pi -i ../k3s-ansible/inventory/sample/hosts.ini ../k3s-ansible/site.yml --private-key ${PRIVATE_KEY_PATH}
	scp pi3:~/.kube/config ~/.kube/config_temp
	sed -i -e "s/default/pik3s/g" ~/.kube/config_temp
	cat ~/.kube/config_temp >> ~/.kube/config
	rm ~/.kube/config_temp
	chmod 0600 ~/.kube/config

namespaces:
	kubectl create namespace monitoring
	kubectl create namespace pihole

.PHONY: pihole
pihole:
	helm repo add mojo2600 https://mojo2600.github.io/pihole-kubernetes/
	helm repo update
	helm upgrade -i \
		pihole \
		mojo2600/pihole \
		--namespace pihole \
		--version 1.7.17 \
		--values helm/pihole/values.yaml \
		--values helm/pihole/dhcp.yaml

PASSWORD := $(shell head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')
pihole-admin:
	kubectl create secret generic pihole-secret \
    	--from-literal password=${PASSWORD} \
    	--namespace pihole

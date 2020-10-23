USERNAME := $(shell whoami)
PRIVATE_KEY_PATH := ~/.ssh/rpi/gh_rpi

image:
	# Ensure sudo does not require password during playbok run for localhost
	@sudo ls > /dev/null
	ansible-playbook -u ${USERNAME} -i inventory/inventory playbooks/imager.yaml

wifi:
	ansible-playbook -u pi -i inventory/inventory playbooks/wifi.yaml --private-key ${PRIVATE_KEY_PATH}

.PHONY: k3s-ansible
k3s-ansible:
	git clone git@github.com:rancher/k3s-ansible.git k3s-tmp
	ansible-playbook -u pi -i k3s-ansible/inventory/sample/hosts.ini k3s-tmp/site.yml --private-key ${PRIVATE_KEY_PATH}
	scp pi3:~/.kube/config ~/.kube/config_temp
	sed -i -e "s/default/pik3s/g" ~/.kube/config_temp
	cat ~/.kube/config_temp >> ~/.kube/config
	rm ~/.kube/config_temp
	chmod 0600 ~/.kube/config
	rm -rf k3s-tmp

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

.PHONY: k8s-dashboard
.ONESHELL:
k8s-dashboard:
	GITHUB_URL=https://github.com/kubernetes/dashboard/releases
	VERSION_KUBE_DASHBOARD=$$(curl -w '%{url_effective}' -I -L -s -S $${GITHUB_URL}/latest -o /dev/null | sed -e 's|.*/||')
	kubectl apply \
		-f https://raw.githubusercontent.com/kubernetes/dashboard/$${VERSION_KUBE_DASHBOARD}/aio/deploy/recommended.yaml
	kubectl apply \
		-f k8s-dashboard/dashboard.admin-user.yml \
		-f k8s-dashboard/dashboard.admin-user-role.yml

	./k8s-dashboard/check-pod.sh
	kubectl -n kubernetes-dashboard \
		describe secret \
		admin-user-token |\
		grep ^token

	echo "\nRun 'kube proxy' then go to the following URL:\nhttp://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/overview?namespace=default"
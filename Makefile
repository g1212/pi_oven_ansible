USERNAME := $(shell whoami)
PRIVATE_KEY_PATH := ~/.ssh/rpi/gh_rpi

image:
	# Ensure sudo does not require password during playbok run for localhost
	@sudo ls > /dev/null
	ansible-playbook -u ${USERNAME} -i inventory/inventory playbooks/imager.yaml

wifi:
	ansible-playbook -u pi -i inventory/inventory playbooks/wifi.yaml --private-key ${PRIVATE_KEY_PATH}

ping:
	ansible -u michaelbeutler --private-key ./id_rsa -i ansible/inventory/hosts.cfg --ssh-common-args='-o StrictHostKeyChecking=no' all -m ping

install:
	ansible-playbook -u michaelbeutler --private-key ./id_rsa -i ansible/inventory/hosts.cfg --ssh-common-args='-o StrictHostKeyChecking=no' ansible/playbook.yml
# nmapVulners
An ansible playbook and bash script that configures a scheduled nmap vulners scan against a target.

1. Ansible playbook is executed.
2. Scripts and dependencies are staged w/in the target host.
3. The script installs it self by creating a cron job.

# Configurations.
Populate variables as necessary over at install_nmap-vulners.yml

	cadence: "0 0 * * *" 			#Schedule in Cron format.
	recipients: "recipient@example.com"	#Multiple recipients separated by comma can be configured.
	sender: "sender@example.com" 		#Address to reflect on the From header.

Scanning targets are configured thru a file targets.txt

# Usage
ansible-playbook -i _inventory.yml_ install_nmap-vulners.yml --extra-vars "host=_target_host_"


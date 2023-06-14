# nmapVulners
An ansible playbook and bash script that configures a scheduled nmap vulners scan against a target.

1. Ansible playbook is executed.
2. Scripts and dependencies are staged w/in the target host.
3. The playbook installs the script by executing the script with the -I paramater.

# Configurations.
Populate variables as necessary over at install_nmap-vulners.yml

	cadence: "0 0 * * *" 			#Schedule in Cron format.
	recipients: "recipient@example.com"	#Multiple recipients separated by comma can be configured.
	sender: "sender@example.com" 		#Address to reflect on the From header.

Scanning targets are configured thru a file targets.txt

# Playbook Usage
ansible-playbook -i _inventory.yml_ install_nmap-vulners.yml --extra-vars "host=_target_host_"

# Script Usage

Usage: nmapVulners.sh -t target -v vulners -r recipient [-s stylesheet] [-I "0 0 1 * *"]

This script executes an Nmap scan using the vulners nse   script
It outputs an xml file and formats the result using a stylesheet
when provided. Results are sent out using mail

Available options:

-h, --help          Print this help and exit

-i, --inventory     [Filepath] Accepts host file inventory each record is separated by \n.
                    does'nt work together with the -t parameter

-t, --target        [String] Accepts inidividual host to scan.
                    does'nt work together with the -i parameter

-v, --vulners       [Filepath] Accepts Vulners script path
                    ie: /usr/share/nmap/scripts/vulners.nse

-r, --recipient     [String] Accepts comma delimited recipient(s)
                    ie: user1@example.com,user2@example.com

-f, --from          [String] Sender Address
                    default: LAPTOP-COAMLVTF

-d, --destination   (optional) [Filepath] directory to store outputs.
                    default: /tmp

-I, --Install       (optional) [String] Accepts cron schedule expressions. Installs the script as a cron job
                    ie: "0 0 1 * *" (https://crontab.guru/#0_0_1_*_*)

EXAMPLES

  nmapVulners.sh -t 192.168.1.1 -v vulners.nse -r recipient@example.com -s ./nmap-bootstrap.xsl
  nmapVulners.sh -i inventory.txt -v /usr/share/nmap/scripts/vulners.nse -r recipient@example.com


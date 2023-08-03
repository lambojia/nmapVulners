Role Name
=========

Installs a scheduled Nmap scan using the vulners NSE script

Requirements
------------

Tested on Ubuntu 22 , the script assumes that GNU mailutils is installed for sending out emails.

Role Variables
--------------

candence:       (required) cron schedule to execute the scan

recipients:     (required) comma delimited list of email recipients. ie: user1@example.com,user2@email.com

sender:         (optional) From header to be used for sending out emails. defaults to the user@hostname when not supplied.

mincvss:        (optional) (decimal value from 1.0 to 10.0) Limit CVEs shown to those with this CVSS score or greater

Dependencies
------------

N/A

Example Playbook
----------------

    - hosts: localhost
      become: yes
      vars
        - cadence: "0 0 * * *"
          recipients: "alef.ambojia@opensense.com"
          sender: "nmapVulners@scanner1.opensense.com"
          mincvss: 1.0
      roles:
        - nmapvulners

License
-------

BSD

Author Information
------------------

N/A

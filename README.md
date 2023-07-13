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
sender:         (optional) From header to be used for sending out emails. defaults to the hostname when not supplied.


Dependencies
------------

N/A

Example Playbook
----------------

    - hosts: localhost
      become: yes
      roles:
        - { role: nmapvulners , cadence: "0 0 * * *" , recipients: "la.ambojia@gmail.com,alef.ambojia@opensense.com" , sender: "postmaster@mailer.alipyo.com"}

License
-------

BSD

Author Information
------------------

N/A

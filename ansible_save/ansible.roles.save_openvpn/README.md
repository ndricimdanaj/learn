# TODO

# Prerequisites
## Ansible

* Ansible installed: https://docs.ansible.com/ansible/latest/intro_installation.html

# SSH

You need to ssh to the vm with sudo rights.

# What does this play do?

* Fetch Netplans
* Save and fetch IpTables in current state
* Fetch for each OpenVPN Instance
    * configs
    * certs (no key)
    * ccd folder and files (tag: ccd)
    * Logfiles (tag: logs)
    * Logrotate files (tag: logrotate)



## skip specific files and folders

add --skiptags with on of the tags mentioned above to not save the files

# TODO

push data structure in ansible vault and upload to git

## Tips

### Troubleshooting for vars

```
ansible vpn01_staging -m debug -a "var=hostvars[inventory_hostname]" 
``` 




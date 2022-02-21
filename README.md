# homelab-public
General homelab scripts, mostly bootstraps for installing and configuring various 
InfoSec and IT software on CentOS 7. 

Here's a short list of some of the things covered in this repo:
 - Ansible scripts for CentOS 7
 - Docker
 - Security Onion
 - Kubernetes
 - Network compliance validation
 - AWS: ephemeral VPN creation, debug EC2 instances for testing, HTTP webhook for SMS notification
 - Certbot for SSL certificate generation and renewal on self-hosted PKI
 - pre-commit scripts for Bash development
 - Domain Name dropcatch monitoring
 - A variety of OS X maintenance and automation
 - Raspberry Pi setup and automation
 - VMware ESXi host patching and config
 - Uninterrupted Power Supply setup and automation

These scripts were intentionally written in Bash to make it super easy for people
with limited Linux experience to run them without running into dependencies issues
or Python version issues. It's designed for homelab newbies to copy and paste or
download and directly run .sh files.

I've started migrating some of this to Ansible for more advanced users, and will
probably migrate some to Python too one day.

Some of the oldest scripts date back to when I worked at [Ziften](https://github.com/ziften/) in 2011 and
have continued writing code while at [Rapid7](https://github.com/rapid7/).

I'm the primary contributor to Rapid7's presales engineering GitHub repository
too: https://github.com/rapid7/presales-engineering/tree/tim-dev

Some of the scripts in this homelab repository are related to some of the Rapid7
scripts.

Here's my homelab hardware that this repo was built to run on.
![Picture of homelab](https://i.imgur.com/LzBtQjL.jpg)

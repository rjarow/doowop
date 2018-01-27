# Doowop

### Mission Statement

Doowop is a set of ansible scripts for deploying Wordpress websites using Docker on Ubuntu Server (16.04 for now)

The idea behind this was to make a reasonably secure deployment for multiple wordpress sites on a single host. After trying other solutions like easyengine, and centminmod I decided to make my own.

I built my own Docker Containers for each as available ones were too heavy, or didnt have the options I wanted within them.

The end goal is to let users get a cheap VPS and manage multiple wordpress installations with quickness and ease.

### Prerequisites

* Ubuntu 16.04 Server, whether VM or Bare Metal
* root access
* Basic understanding of ansible and docker

### General Information
The bootstrap playbook takes care of bootstrapping the entire server and getting ready for Wordpress deployments.

The doowop playbooks are for creating, destroying, stopping and starting wordpress hosted domains.

By default, these use my custom made Wordpress and MariaDB Docker containers.

For more information on the containers see their respective repositories.

* [Wordpress](https://github.com/rjarow/danwp)
* [MariaDB](https://github.com/rjarow/alpine-mariadb)

All playbooks can be run locally or on a remote host.

## Steps taken by the bootstrap playbook

* Downloads and updates OS.
* Adds Ansible's official PPA to repos.
* Installs latest Ansible.
* Adds official Docker PPA to repos.
* Installs latest Docker-CE.
* Adds an admin user to system for managing/running Docker Containers.
* Creates a Docker Network specific for doowop deployments.
* Installs UFW Firewall.
* Configures firewall to allow ssh, and web traffic only.
* Pulls/Configures [nginx-proxy](https://github.com/jwilder/nginx-proxy)
* Pulls/Configures [let's encrypt helper](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion)
* Installs [dry](https://github.com/moncho/dry) - a minimal cli Docker monitoring tool.
* Installs [portainer](https://portainer.io/) - a web ui for managing Docker. (not installed by default)
* Installs [borgbackup](https://www.borgbackup.org/) - A wonderful cli backup tool.


## Steps taken by the dw_deploy playbook

* Asks for your domain and email to setup the site and LetsEncrypt SSL.
* Pulls and creates 2 Docker containers per website (Wordpress and Database)
* Bind mounts the working directories to the local file system.
* Generates passwords for the root mysql, and the wp database.
* Takes all user input and variables and deploys Wordpress and DB.

## Steps taken by the dw_destroy playbook

* Destroys all containers.
* Destroys all data mountpoints.
* Destroys all configurations.
* Obviously be very careful with this one.

## Steps taken by dw_stop and dw_start playbook

* Hopefully obvious. :)


### Settings

There are 2 files at minimum to modify before running this playbook.

The inventory file, is necessary to modify the IP(s) of servers as part of the doowop group that the scripts are set to run against.

The default is set to localhost, if you choose to use it remotely, comment this out and change the commented IP'd line to the desired IP

```
[doowop]

### Default is to run doowop scripts locally. Adjust as necessary.
#127.0.0.1          ansible_connection=local


### uncomment this and change IP if using doowop on remote host. Make sure above is commented as well.
### change the ansible_user and connection type as necessary.
10.184.11.232   ansible_connection=ssh        ansible_user=root
```

The group_vars/all file has a lot of variables you can change to your liking. The defaults are sane, however I would change the docker_user variable to your liking.

This file is documented and should be self explanatory. I'm not pasting it here to keep this README somewhat short. (lol)

## Quick Test Bootstrap

If you are running this script directly on the server I have written a small bash script to deploy everything in 1 command. This is meant to demonstrate an automated workflow, and should only be used for testing.

```
curl -sSL https://raw.githubusercontent.com/rjarow/doowop/master/bootstrap_local.sh | bash
```
This script can be run on a clean ubuntu 16.04 server. It downloads git, installs ansible and puts the doowop scripts in /opt/doowop, then kicks off the bootstrap playbook. Feel free to modify for your own use. It uses sane defaults, but I do not suggest using this method other than for testing.

## Regular Bootstrap

Get yourself an Ubuntu 16.04 VM or Bare Metal server.
Get root access

Please git clone this repo to your desired place. I suggest /opt/doowop.

```
git clone https://github.com/rjarow/doowop.git /opt/doowop
```

Modify the settings mentioned above (inventory and group_vars/all)

```
cd /opt/doowop
vim inventory
vim group_vars/all
```
Then run as root

```
ansible-playbook bootstrap.yml
```

Obviously you may need some different switches (maybe -k ?) but this is on you to modify. The default is expected to run as root. I have used become: yes in the playbooks so you can execute this as a sudo user.

You may also want to move the inventory / ansible.cfg to ansibles global config (/etc/ansible) so you do not need to execute these from the /opt/doowop location. Again, your call.

Go grab a coffee, this will take a few mins!

Once it's done you'll have a server ready for Wordpress deployments!

One last thing you'll want to do is set the password for the user you put under docker_user in the variables. You'll want to use this user going forward to manage sites, and deploy new ones. Of course this can still be done as root, but not suggested.

A good simple tutorial for that can be found [here](https://www.digitalocean.com/community/tutorials/how-to-create-a-sudo-user-on-ubuntu-quickstart) - Since the user exists you simply just need to set the password and add to sudo group

```
passwd runuser
usermod -aG sudo runuser
```
Make note of this password as you'll need to run commands as root and login to the server.

I also suggest setting up SSH keys for logins and disabling passwords, and completely disabling your root ssh login, however that is past the scope of this documentation.

### Wordpress Deployment and management

The dw_deploy.yml playbook is designed to ask the domain for setup, and the email to register the letsencrypt SSL.

*** IMPORTANT NOTE ***

Make sure your intended domain is pointing, and resolves to the IP of the server you want to run wordpress on. Not doing so will cause the letsencrypt ssl to fail and the site not to load correctly.

I'll add docs how to fix this if you run into this, soon.


Example run:
```
ansible-playbook dw_deploy.yml

What is the TLD You would like to setup? (ie mydomain.com): test.com
What is the email to send letsencrypt (ssl) emails for this domain?: test@test.com

PLAY [doowop] ***********

...

TASK [Variable Information] **************************************************************************************************************************
ok: [192.168.121.86] => {
    "msg": "test.com_db -- MYSQL ROOT PASS: v44D7A+fs9uVId36  MYSQL_USER: wordpress  MYSQL_PASSWORD: pAqYdDfLFmvPK6Rb -- Writing to >> /config/test.com.txt"
}

TASK [Finished!] *************************************************************************************************************************************
ok: [192.168.121.86] => {
    "msg": "Please visit https://test.com and finish your wordpress setup!"
}
```
As you can see above, you'll need to go to the website and finish your wordpress login and etc. I am thinking of adding functionality to do this via the playbook in the future.

You'll also have the mysql login info saved to your configdir for safe keeping. It will be only readable by the root account.

Both the web and db will live in the sitedir defined in the variables, and you'll be able to modify them via the docker_user.

Example:
```
runuser@ubuntu1604:/root$ cd ~
runuser@ubuntu1604:~$ cd /sites/test.com/
runuser@ubuntu1604:/sites/test.com$ ls
db  web
runuser@ubuntu1604:/sites/test.com$ cd web/
runuser@ubuntu1604:/sites/test.com/web$ nano wp-config.php
```

If you run docker container ls you'll see the underlying of containers running.

```
runuser@ubuntu1604:/sites/test.com/web$ docker container ls
CONTAINER ID        IMAGE                                    COMMAND                  CREATED             STATUS              PORTS                                      NAMES
97d5ba6d47f3        containah/danwp                          "/init"                  15 minutes ago      Up 15 minutes       80/tcp                                     test.com_wp
7405807d9eff        containah/alpine-mariadb                 "/init"                  16 minutes ago      Up 16 minutes       3306/tcp                                   test.com_db
d1942e9241b5        jrcs/letsencrypt-nginx-proxy-companion   "/bin/bash /app/en..."   2 hours ago         Up 2 hours                                                     nginx-companion
e56f4485f5fd        jwilder/nginx-proxy                      "/app/docker-entry..."   2 hours ago         Up 2 hours          0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp   nginx-proxy
```

All containers are set to always run unless-stopped.

The dw_destroy.yml will destroy the wordpress site and databases, this is a completely destructive process

Example:
```
ansible-playbook dw_destroy.yml

What is the TLD You would like to DESTROY ( ex. mydomain.com ): test.com
Are you sure you want to do this? Type yes to continue deleting everything for this domain: yes

PLAY [doowop] *************************************************************************************************************************************************************************************

TASK [Gathering Facts] ****************************************************************************************************************************************************************************
ok: [XXX.XXX.XXX.XXX] => {


TASK [WARNING] ************************************************************************************************************************************************************************************
ok: [XXX.XXX.XXX.XXX] => {
    "msg": "THIS IS A DESTRUCTIVE PROCESS. YOU WILL BE DELETING ALL RUNNING COPIES AND DATA FOR test.com"
}
...

```
Once done you can see we're left with the 2 nginx containers and all traces of the wordpress for 'test.com' are gone

```
docker container ls
CONTAINER ID        IMAGE                                    COMMAND                  CREATED             STATUS              PORTS                                      NAMES
d1942e9241b5        jrcs/letsencrypt-nginx-proxy-companion   "/bin/bash /app/en..."   2 hours ago         Up 2 hours                                                     nginx-companion
e56f4485f5fd        jwilder/nginx-proxy                      "/app/docker-entry..."   2 hours ago         Up 2 hours          0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp   nginx-proxy

```

the dw_stop.yml and dw_start.yml simply ask for the domain of the website you want to stop or start and does that action.

All playbooks have shebangs so that you can make them executable.

```
$ chmod +x /opt/doowop/dw_deploy.yml
$ /opt/doowop/dw_deploy.yml
```



## Built With

* [VSCode](https://code.visualstudio.com/) - Editor of choice these days.
* [Docker](https://docker.com) - Who loves containers? We love containers!
* [Ansible](https://ansible.com) - Push Automation <3
* [nginx-proxy](https://github.com/jwilder/nginx-proxy) - the frontend to the wordpress websites
* [letsencrypt-companion](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion) - Makes SSL easy!
* [Wordpress](https://wordpress.org) - The blogging platform
* [MariaDB](https://mariadb.org/) - Database software
* [Ubuntu](https://www.ubuntu.com/) - Host OS


## Authors

* **Rich J** - [rjarow](https://github.com/rjarow)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## RoadMap

* Add support for debian/centos ?
* Add drupal /joomla support ?
* Add static website (hugo/jekyll) support ?
* Add GravCMS support
* Docker containers for each of these.
* TravisCI testing/builds to containah.com
* Let me know if you have any other suggestions!


## tl;dr

* Fresh Ubuntu 16.04 server.
```
ssh root@server
apt install software-properties-common git -y
add-apt-repository ppa:ansible/ansible -y
apt update
apt install ansible
mkdir -p /opt/doowop
git clone https://github.com/rjarow/doowop.git /opt/doowop
vim /opt/doowop/inventory
vim /opt/doowop/group_vars/all
ansible-playbook /opt/doowop/bootstrap.yml
passwd runuser
usermod -aG sudo runuser
logout
ssh runuser@server
cd /opt/doowop



```
* Point domain to IP of server
* Wait for propagation
```
sudo ansible-playbook /opt/doowop/dw_deploy.yml
```

Enjoy!

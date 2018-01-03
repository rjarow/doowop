## DOOWOP

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

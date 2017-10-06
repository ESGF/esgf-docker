.. _docker_swarm_setup_on_linux:

**************************
Docker Swam Setup on Linux
**************************

Abstract
========

This page instructs on how to setup a Docker Swarm cluster on a single Linux system, 
using virtual machines.
The examples of shell instructions are specific to the CentOS system but other
Linux systems (like Debian base distributions) are just different from the package
manager instructions. This Swarm can be effectively used as a test environment for 
deploying ESGF software stack on a multiple-host cluster.

Notes
=====

- shell instructions examples assume that you have administrator privileges. 
- shell instructions examples are not updated, so always refer to the given
  documentations.
- If you have a Linux kernel security module installed (like selinux), we assume
  that you know how to configure it for docker and swarm cluster.
- If you want to run ESGF on a cluster of hosts, the sections Docker CE
  installation and Firewall configuration are sufficient.

Tested versions
===============

- CentOS 7.4.1708
- Docker 17.09.0-ce, build afdb6d4
- Docker Machine 0.12.2
- Docker Machine KVM driver 0.10.0

Docker CE installation
======================

Follow the instructions specifics to your Linux distribution `here
<https://www.docker.com/community-edition>`__

The specific instructions for CentOS system are `here <https://docs.docker.com/engine/installation/linux/docker-ce/centos/>`__.

Manage the Docker daemon needs administrator privileges (using sudo or login as
root). You can manage it as a non root user by creating a group named docker and
add your user account to it. The procedure is described `here <https://docs.docker.com/engine/installation/linux/linux-postinstall/#manage-docker-as-a-non-root-user>`__.

Firewall configuration
======================

According to the swarm `guide <https://docs.docker.com/engine/swarm/swarm-tutorial/#open-protocols-and-ports-between-the-hosts>`__, the following
ports have to be open (direction INPUT and OUTPUT, states NEW and ESTABLISHED):

- TCP port 2376
- TCP port 2377
- TCP and UDP port 7946
- UDP port 4789

and of course, TCP port 22 (ssh) have to be open.

We also believe that localhost interface must have full access so as to connect
to the ESGF components.

Examples of iptables configuration::

  # give the localhost interface full access
  iptables -A INPUT  -i lo -j ACCEPT
  iptables -A OUTPUT -o lo -j ACCEPT

  # open the swarm ports
  iptables -A INPUT  -p tcp --dport 2377 -j ACCEPT
  iptables -A INPUT  -p tcp --dport 7946 -j ACCEPT
  iptables -A INPUT  -p udp --dport 7946 -j ACCEPT
  iptables -A INPUT  -p udp --dport 4789 -j ACCEPT
  
  # open the docker machine port
  iptables -A INPUT  -p tcp --dport 2376 -j ACCEPT

Notes:

- The Docker daemon adds some rules when it starts. If you reset iptables, so
  don't forget to restart Docker daemon::
  
    service docker restart

- The virtualization infrastructure creates some network interfaces, so you have
  to give them full access.

Virtualization infrastructure
=============================

Docker Machine is a command line tool that automate the creation of Virtual 
Machines (VMs) with an minimalist image of Linux with Docker engine installed.
Nevertheless, Docker Machine relies on a virtualization infrastructure.
Under Linux systems, you got plenty of choices: KVM, Xen, VirtualBox, etc.

This `link <https://docs.docker.com/machine/drivers/>`__ lists the supported 
virtualization infrastructures by Docker Inc. Although KVM is not supported 
by Docker Inc, KVM is supported by the docker community. This example give you
some instructions to install and manage VMs with KVM and Virtual Machine Manager
on a CentOS system::

  yum -f install qemu-kvm.x86_64 virt-manager.noarch libvirt.x86_64

and don't forget to give full access to the interfaces created by kvm (virbr0 and
virbr1)::

  iptables -A INPUT -i virbr0 -j ACCEPT
  iptables -A INPUT -i virbr1 -j ACCEPT
  iptables -A FORWARD -i virbr0 -j ACCEPT
  iptables -A FORWARD -o virbr0 -j ACCEPT
  iptables -A FORWARD -i virbr1 -j ACCEPT
  iptables -A FORWARD -o virbr1 -j ACCEPT

Docker Machine
==============

Docker Machine is a tool that manage VMs with docker engine installed.
This tool is perfect to simulate a cluster of swarm nodes on a single host.
However, Docker Machine is not provided alongside the Docker installation.
This `link <https://github.com/docker/machine/releases/>`__ explains how to install Docker Machine.

example of the installation of the version 0.12.2::

  curl -L https://github.com/docker/machine/releases/download/v0.12.2/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine
  chmod +x /tmp/docker-machine
  cp /tmp/docker-machine /usr/local/bin/docker-machine

And don't forget to add /usr/local/bin into your PATH environment variable::
  
  export PATH=/usr/local/bin/:$PATH

Docker Machine driver
=====================

Docker Machine needs a driver to create VMs. According to the virtualization
infrastructure that you installed, you have to install the associated driver.
This `link <https://docs.docker.com/machine/drivers/>`__ lists the supported 
virtualization infrastructures. Note that KVM is not supported by Docker Inc but
the docker community. This `link <https://github.com/dhiltgen/docker-machine-kvm/releases>`__ give you the procedure of the KVM driver installation.

The example of the Docker Machine KVM driver version 0.10.0::

    curl -L https://github.com/dhiltgen/docker-machine-kvm/releases/download/v0.10.0/docker-machine-driver-kvm-centos7 > /usr/local/bin/docker-machine-driver-kvm
    chmod +x /usr/local/bin/docker-machine-driver-kvm

Execution
=========

You can follow the Docker Machine get started guide `here <https://docs.docker.com/machine/get-started/>`__ or our `documentation <https://esgf.github.io/esgf-docker/docker_swarm_setup_on_macosx.html>`__ concerning MacOSX systems.
You also can use our script that automate the creation of
docker machines and the creation of the swarm cluster::

  # creates 2 VMs using KVM, named node0 and node1
  # and setup a swarm cluster with these VMs where node0 is the swarm manager
  scripts/setup_swarm_cluster.sh -d kvm -n 2

Creating VMs can take few minutes.

Note that you can pass arguments to the Docker Machine driver with the command
line option -a. For example, if you want to set the VMs RAM size to 2048 Mo
(faster VMs ; default is 1024 Mo)::

  scripts/setup_swarm_cluster.sh -d kvm -n 2 -a "--kvm-memory 2048"

About managing docker machine VMs::

  docker-machine ls # list the VMs
  docker-machine ssh node0 # log onto the VM named node0
  docker-machine rm node0 node1 # delete the VMs named node0 and node1
  eval $(docker-machine env node0) # so as to issue docker commands with 
                                   # the node0 environment

As an example, these instructions completely shutdown ESGF stack and VMs::

  bash # don't mess with variable environment settings because
  eval $(docker-machine env node0) # we have switch to the node0 context
  docker stack rm esgf-stack # so as to shutdown ESGF stack because node0 is the swarm manager
  exit # optionally exit the subprocess bash
  docker-machine rm node0 node1 # node2 and so onto ; delete the VMs created by docker-machine
  
Associate the IP address of the Swarm manager node to the hostname
you intend to use to access the ESGF services. For example if 
$ESGF_HOSTNAME=my-node.esgf.org::

      sudo vi /etc/hosts
      192.168.99.100 my-node.esgf.org

Where 192.168.99.100 is an example of the ip address of node0. But Note that
because of the Docker Swarm routing mesh capability, the IP
address above can be that of any node in the Swarm, and that URLs
starting with http(s)://my-node.esgf.org/... can be used to access any
of the ESGF services in the stack, no matter on which node they are deployed.
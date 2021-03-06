# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'json'

# Vagrant configuration
Vagrant.configure(2) do |config|
  config.vm.box = "cedadev/centos7"

  # Use a fixed IP on the local network
  config.vm.network :private_network, ip: "192.168.100.100"

  # Set some virtualbox flags to improve time synchronisation between host and guest
  config.vm.provider :virtualbox do |v|
    # 512MB RAM is not really enough
    v.memory = 4096
    # sync time every 10 seconds
    v.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-interval", 10000 ]
    # adjustments if drift > 100 ms
    v.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-min-adjust", 100 ]
    # sync time on restore
    v.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-on-restore", 1 ]
    # sync time on start
    v.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-start", 1 ]
    # at 1 second drift, the time will be set and not "smoothly" adjusted
    v.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 1000 ]
  end

  config.vm.provision :shell, inline: <<-SHELL
    set -euo pipefail
    echo "Installing roocs/mini-esgf-data into /test_data..."
    curl -fsSL https://github.com/roocs/mini-esgf-data/tarball/master | tar -xz --strip-components=1 -C / */test_data
  SHELL

  # Provision the VM with our Ansible playbook
  config.vm.provision :ansible do |ansible|
    ansible.playbook = "deploy/ansible/playbook.yml"
    # Configure the datasets from mini-esgf-data
    # Use group_vars to simulate the advice in the documentation
    # However, because the Ansible provisioner doesn't have a native group_vars
    # property, like it does for {extra,host}_vars, we need to convert to JSON
    data_mounts = [
      {
        host_path: "/test_data",
        mount_path: "/test_data"
      }
    ]
    data_datasets = [
      {
        name: "CMIP5",
        path: "esg_cmip5",
        location: "/test_data/badc/cmip5/data"
      },
      {
        name: "CORDEX",
        path: "esg_cordex",
        location: "/test_data/group_workspaces/jasmin2/cp4cds1/vol1/data/c3s-cordex"
      }
    ]
    solr_replicas = [
      {
        name: "llnl",
        master_url: "https://esgf-node.llnl.gov/solr"
      }
    ]
    ansible.groups = {
      "data" => ["default"],
      "index" => ["default"],
      "all:vars" => {
        "hostname" => "192.168.100.100.nip.io",
        "image_tag" => "future-architecture",
      },
      "data:vars" => {
        "data_mounts" => "#{data_mounts.to_json}",
        "data_datasets" => "#{data_datasets.to_json}"
      },
      "index:vars" => {
        "solr_replicas" => "#{solr_replicas.to_json}"
      }
    }
  end
end

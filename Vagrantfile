# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrant configuration
Vagrant.configure(2) do |config|
  config.vm.box = "cedadev/centos7"

  # Use a fixed IP on the local network
  config.vm.network :private_network, ip: "192.168.100.100"

  # Set some virtualbox flags to improve time synchronisation between host and guest
  config.vm.provider :virtualbox do |virtualbox|
    # sync time every 10 seconds
    virtualbox.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-interval", 10000 ]
    # adjustments if drift > 100 ms
    virtualbox.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-min-adjust", 100 ]
    # sync time on restore
    virtualbox.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-on-restore", 1 ]
    # sync time on start
    virtualbox.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-start", 1 ]
    # at 1 second drift, the time will be set and not "smoothly" adjusted
    virtualbox.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 1000 ]
  end

  # Provision the VM with our Ansible playbook
  config.vm.provision :ansible do |ansible|
    ansible.playbook = "deploy/ansible/playbook.yml"
    ansible.groups = { "data" => ["default"] }
  end
end

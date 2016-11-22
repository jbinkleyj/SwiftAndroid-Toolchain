# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/wily64"
  config.vm.provision "shell", path: "provisioner.sh", privileged: false

  config.vm.provider "virtualbox" do |v|
    v.memory = 4096
    v.cpus = 3
  end

end


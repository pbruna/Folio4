# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "ubuntu-14.04"
  config.vm.network "forwarded_port", guest: 3306, host: 3306
  config.vm.provision "puppet" do |puppet|
      puppet.manifests_path = "Vagrant/puppet/manifests"
      puppet.manifest_file = "default.pp"
    end
end

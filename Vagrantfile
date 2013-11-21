# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "precise32"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "http://files.vagrantup.com/precise32.box"

  # Add a host-only network adapter, for samba etc.
  # config.vm.network :hostonly, "192.168.33.11"
  config.vm.network "private_network", ip: "192.168.33.11"


  # Set the "/vagrant" share up so it's shared with the web server.
  config.vm.synced_folder "./", "/vagrant", :owner => "vagrant", :group => "www-data", :mount_options => ["dmode=775","fmode=665"]


  # Configure puppet.
  box_path = File.expand_path(__FILE__ + '/..')
  puppet_path = box_path + '/puppet';
  config.vm.provision :puppet do |puppet|
    puppet.manifest_file = "base.pp"
    puppet.manifests_path = puppet_path + "/manifests"
    puppet.module_path = [ puppet_path + "/modules" ]
  end

end

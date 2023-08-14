Vagrant.configure("2") do |config|
    config.vm.provision "shell", inline: <<-SHELL
        apt-get update -y
        echo "10.0.0.10  master-node" >> /etc/hosts
        echo "10.0.0.11  worker-node01" >> /etc/hosts
        echo "10.0.0.12  worker-node02" >> /etc/hosts
    SHELL
    config.vm.box = "generic/debian10"
    config.vm.define "master" do |master|
      # master.vm.box = "boxomatic/debian-11"
      master.vm.hostname = "master-node"
      master.vm.network "private_network", ip: "10.0.0.10"
      master.vm.provider "vmware_fusion" do |vb|
          # vb.memory = 4048
          vb.memory = 2048
          vb.cpus = 2
      end
      master.vm.provision "shell", path: "scripts/common.sh"
      master.vm.provision "shell", path: "scripts/master.sh"
      config.vm.synced_folder "./configs", "/vagrant/configs", SharedFoldersEnableSymlinksCreate:false
    end

    (1..2).each do |i|
  
    config.vm.define "node0#{i}" do |node|
      # node.vm.box = "boxomatic/debian-11"
      node.vm.hostname = "worker-node0#{i}"
      node.vm.network "private_network", ip: "10.0.0.1#{i}"
      node.vm.provider "vmware_fusion" do |vb|
          # vb.memory = 2048
          vb.memory = 1048
          vb.cpus = 1
      end
      node.vm.provision "shell", path: "scripts/common.sh"
      node.vm.provision "shell", path: "scripts/node.sh"
    end
    
    end
  end
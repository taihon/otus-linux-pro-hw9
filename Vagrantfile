# -*- mode: ruby -*-
# vim: set ft=ruby :
home = ENV['HOME']
ENV["LC_ALL"] = "en_US.UTF-8"

MACHINES = {
  :bashscript => {
        :box_name => "centos/7",
        :box_version => "1804.02",
        :ip_addr => '192.168.11.102',
    :disks => {
    }
  },
}

Vagrant.configure("2") do |config|

    config.vm.box_version = "1804.02"
    MACHINES.each do |boxname, boxconfig|
  
        config.vm.define boxname do |box|
  
            box.vm.box = boxconfig[:box_name]
            box.vm.host_name = boxname.to_s
  
            #box.vm.network "forwarded_port", guest: 3260, host: 3260+offset
  
            box.vm.network "private_network", ip: boxconfig[:ip_addr]
  
            box.vm.provider :virtualbox do |vb|
                    vb.customize ["modifyvm", :id, "--memory", "256"]
                    needsController = false
				boxconfig[:disks].each do |dname, dconf|
					unless File.exist?(dconf[:dfile])
					vb.customize ['createhd', '--filename', dconf[:dfile], '--variant', 'Fixed', '--size', dconf[:size]]
									needsController =  true
					end
				end
				if needsController == true
					vb.customize ["storagectl", :id, "--name", "SATA", "--add", "sata" ]
					boxconfig[:disks].each do |dname, dconf|
						vb.customize ['storageattach', :id,  '--storagectl', 'SATA', '--port', dconf[:port], '--device', 0, '--type', 'hdd', '--medium', dconf[:dfile]]
					end
				end
            end
        	# hw 3.1
        box.vm.provision "shell", inline: <<-'SHELL'
          mkdir -p ~root/.ssh
          cp ~vagrant/.ssh/auth* ~root/.ssh
          yum install -y mailx
          SHELL
    	end
  	end
end
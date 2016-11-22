# create application from  ravello blueprint: OPTLC-OSPN_v4.0_AdvancedNetworking-v1.3-postinstall-bp
# publish
# add your SSH key to ssh-agent
# get DNS name for workstation, update the following variable
BASTION=0workstation-nsabineosp-dwjz8qc9.srv.ravcloud.com

# No more changes needed 

#wget https://download.fedoraproject.org/pub/fedora/linux/releases/24/CloudImages/x86_64/images/Fedora-Cloud-Base-24-1.2.x86_64.qcow2 
#virt-customize -a Fedora-Cloud-Base-24-1.2.x86_64.qcow2 --run-command 'dnf -y erase cloud-init'
#virt-customize -a Fedora-Cloud-Base-24-1.2.x86_64.qcow2 --run-command 'dnf install -y python2 python2-dnf libselinux-python'
#virt-customize -a Fedora-Cloud-Base-24-1.2.x86_64.qcow2 --mkdir /home/fedora/.ssh/
#virt-customize -a Fedora-Cloud-Base-24-1.2.x86_64.qcow2 --copy-in authorized_keys:/home/fedora/.ssh/
#virt-customize -a Fedora-Cloud-Base-24-1.2.x86_64.qcow2 --chmod 600:/home/fedora/.ssh/authorized_keys
#virt-customize -a Fedora-Cloud-Base-24-1.2.x86_64.qcow2 --run-command 'chown 1000:1000 /home/fedora/.ssh/authorized_keys'
#mv Fedora-Cloud-Base-24-1.2.x86_64.qcow2 fedora-custom.qcow2
#scp fedora-custom.qcow2 cloud-user@$BASTION:

# copy files to bastion host
scp setup.sh cloud-user@$BASTION:

# run setup script
ssh cloud-user@$BASTION 'chmod 755 setup.sh'
ssh cloud-user@$BASTION 'screen -dmLS setup sudo ./setup.sh'

# for socks proxy (accessing the deployed wordpress instance) 
#ssh -D 9999 cloud-user@$BASTION 

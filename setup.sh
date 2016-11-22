# For OpenStack Workshop 

# install dependencies and setup host network config
HOSTS="ctrl.example.com comp00.example.com comp01.example.com net00.example.com net01.example.com net02.example.com"
for HOST in $HOSTS;
do
  ssh $HOST "yum install -y openstack-utils openstack-selinux iptables-services"
  ssh $HOST "systemctl stop firewalld ; systemctl disable firewalld ; systemctl start iptables ; systemctl start ip6tables ; systemctl enable iptables ; systemctl enable ip6tables ; systemctl stop NetworkManager ; systemctl disable NetworkManager"
  ssh $HOST /root/network_bonding_setup.sh
  ssh $HOST 'echo "UseDNS no" >> /etc/ssh/sshd_config; systemctl restart sshd'
done

# fix broken cinder config
ssh ctrl.example.com "openstack-config --set /etc/cinder/cinder.conf keystone_authtoken auth_uri http://192.168.0.20:5000 "
ssh ctrl.example.com "openstack-config --set /etc/cinder/cinder.conf keystone_authtoken auth_url http://192.168.0.20:35357 "
ssh ctrl.example.com "openstack-config --set /etc/cinder/cinder.conf keystone_authtoken auth_plugin password "
ssh ctrl.example.com "openstack-config --set /etc/cinder/cinder.conf keystone_authtoken project_domain_id default "
ssh ctrl.example.com "openstack-config --set /etc/cinder/cinder.conf keystone_authtoken user_domain_id default "
ssh ctrl.example.com "openstack-config --set /etc/cinder/cinder.conf keystone_authtoken project_name services "
ssh ctrl.example.com "openstack-config --set /etc/cinder/cinder.conf keystone_authtoken username cinder "
ssh ctrl.example.com "openstack-config --set /etc/cinder/cinder.conf keystone_authtoken password 113b6b9684c04c3d "
ssh ctrl.example.com "openstack-service restart cinder"

# add flat driver for public network
ssh ctrl.example.com "openstack-config --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 type_drivers vxlan,flat ;  openstack-service restart neutron"

# fix DNS resolution
ssh ctrl.example.com 'echo "nameserver 8.8.8.8" >> /etc/resolv.conf'

# import RHEL
#ssh ctrl.example.com "wget https://nicksabine.com/workshop/rhel-guest-image-7.3-35.x86_64.qcow2"
#ssh ctrl.example.com "source keystonerc_admin ; glance image-create --name rhel7.3 --visibility public --disk-format qcow2 --container-format bare --file rhel-guest-image-7.3-35.x86_64.qcow2 --progress"

# import Fedora
#ssh ctrl.example.com 'wget https://download.fedoraproject.org/pub/fedora/linux/releases/24/CloudImages/x86_64/images/Fedora-Cloud-Base-24-1.2.x86_64.qcow2'
#ssh ctrl.example.com "source keystonerc_admin ; glance image-create --name fedora --visibility public --disk-format qcow2 --container-format bare --file Fedora-Cloud-Base-24-1.2.x86_64.qcow2 --progress"

# import Fedora-Custom
ssh ctrl.example.com 'wget https://nicksabine.com/workshop/fedora.qcow2'
ssh ctrl.example.com "source keystonerc_admin ; glance image-create --name fedora --visibility public --disk-format qcow2 --container-format bare --file fedora.qcow2 --progress"

# allow ports in default security group (removed - handled by playbook)
#ssh ctrl.example.com "source keystonerc_admin ; nova secgroup-add-rule default tcp 22 22 0.0.0.0/0"
#ssh ctrl.example.com "source keystonerc_admin ; nova secgroup-add-rule default tcp 80 80 0.0.0.0/0"
#ssh ctrl.example.com "source keystonerc_admin ; nova secgroup-add-rule default tcp 443 443 0.0.0.0/0"
#ssh ctrl.example.com "source keystonerc_admin ; nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0"

# private network
ssh ctrl.example.com "source /root/keystonerc_admin; neutron net-create internal1 ;  neutron subnet-create --allocation-pool start=192.168.1.2,end=192.168.1.254 --gateway 192.168.1.1 --dns-nameserver 192.168.0.2 --name subnet1 internal1 192.168.1.0/24 ; "

# public network
ssh ctrl.example.com " source ~/keystonerc_admin ;  neutron net-create public --router:external=True --provider:network_type flat --provider:physical_network external --shared; neutron subnet-create --name public1 --gateway 10.10.10.1 --allocation-pool start=10.10.10.64,end=10.10.10.128 --disable-dhcp public 10.10.10.0/24"

# router
ssh ctrl.example.com " source ~/keystonerc_admin ; neutron router-create router1 ; neutron router-gateway-set router1 public ; neutron router-interface-add router1 subnet1 ; openstack ip floating create public"

# deploy test rhel instance
#ssh ctrl.example.com ' source ~/keystonerc_admin ; net1=$(openstack network show -c id -f value internal1) ; openstack server create --image rhel7.3 --flavor m1.small --security-group default --nic net-id=$net1 vm1 '

# assign floating IP to test instance
#ssh ctrl.example.com ' source ~/keystonerc_admin ; ip1=$(openstack ip floating list -c IP -f value) ; openstack ip floating add $ip1 vm1 '

# config ansible requirements on workstation / bastion
rpm -i https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y ansible python-pip gcc python-devel openssl-devel git
pip install --upgrade pip
pip install shade


echo "########################################################################"
echo "# Automated portion of workshop setup script done.                     #"
echo "# Now run the ansible portion manually for maximum fun. (see setup.sh) #"
echo "########################################################################"

# don't automatically run the rest
exit 0

# complete the following on bastion host, as root:

# workshop ansible playbooks
git clone https://github.com/nsabine/openstack-workshop

pushd openstack-workshop

# Get admin password
eval $(ssh ctrl.example.com "grep OS_PASSWORD ~/keystonerc_admin")

# create wordpress user account
ansible-playbook -e "action=user admin_password=$OS_PASSWORD env=openstack" site.yml

echo "Log on to horizon as wordpress / wordpress"
echo " then browse Network - Topology"
read -p "Press enter to contine"

# deploy the application
ansible-playbook -e "action=apply admin_password=$OS_PASSWORD env=openstack" site.yml

popd

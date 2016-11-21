# create application from  ravello blueprint: OPTLC-OSPN_v4.0_AdvancedNetworking-v1.3-postinstall-bp
# publish
# add your SSH key to ssh-agent
# get DNS name for workstation, update the following variable
#BASTION=0workstation-nsabineosp-pnqzihkj.srv.ravcloud.com
BASTION=0workstation-nsabineosp2-gjisg7pc.srv.ravcloud.com

# No more changes needed 


# copy files to bastion host
scp setup.sh cloud-user@$BASTION:
#scp clouds.yaml cloud-user@$BASTION:

# configure ansible auth
#ssh -t cloud-user@$BASTION 'sudo mkdir -p /root/.config/openstack/; sudo mv /home/cloud-user/clouds.yaml /root/.config/openstack/'

# run setup script
ssh cloud-user@$BASTION 'chmod 755 setup.sh'
ssh cloud-user@$BASTION 'screen -dmLS setup sudo ./setup.sh'

# for socks proxy (accessing the deployed wordpress instance) 
#ssh -D 9999 cloud-user@$BASTION 

#!/bin/bash
# Redirect the user-data output to the console logs
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

#Run Ansible playbook for server setup using provided inputs
echo '${ANSIBLE_INPUTS}' > /root/ansible_inputs.json
/usr/local/bin/ansible-playbook /root/deployment.yml -e '@/root/ansible_inputs.json'

#Install CIFs
yum -y install cifs-utils

#Create Groups
groupadd -g 500 batch
groupadd -g 1012200044 e5fsadmin
groupadd -g 1012200082 csi
groupadd -g 223800273 bulk-live
groupadd -g 223800210 gateway
groupadd -g 1012200011 e5fs

#Create Users
useradd -m -u 3651 batenvp1 -g batch
useradd -m -u 3653 batenvp1rep -g batch
useradd -m -u 223800273 bulk-live -g bulk-live -G e5fsadmin,csi,batch
useradd -m -u 223800210 gateway -g gateway -G e5fsadmin,csi,batch
useradd -u 1012200011 e5fs -g e5fs -G e5fsadmin

#Set permissions
chmod 775 /home/batenvp1
chmod 775 /home/batenvp1rep
chmod 755 /home/bulk-live
chmod 777 /home/gateway

#Create /home/bulk-live/bulkimage dir and permissions & ownership
mkdir -p /home/bulk-live/bulkimage
chmod 755 /home/bulk-live/bulkimage
chown root:root /home/bulk-live/bulkimage

#Create /home/gateway/docprinting dir and permissions & ownership
mkdir -p /home/gateway/docprinting
chmod 777 /home/gateway/docprinting
chown root:root /home/gateway/docprinting

#Create /home/gateway/dasapps dir and permissions & ownership
mkdir -p /home/gateway/dasapps
chmod 777 /home/gateway/dasapps
chown root:root /home/gateway/dasapps

#Create /home/gateway/main dir and permissions & ownership
mkdir -p /home/gateway/main
chmod 775 /home/gateway/main
chown gateway:gateway /home/gateway/main

#Create /home/gateway/printroom dir, permissions & ownership
mkdir -p /home/gateway/printroom
chmod 777 /home/gateway/printroom
chown root:root /home/gateway/printroom

#Create /home/gateway/wlenvp1letteroutput dir & permissions
mkdir -p /home/gateway/wlenvp1letteroutput
chmod 777 /home/gateway/wlenvp1letteroutput

#Create /e5fs/lfp_print_files dir, permissions & ownership
mkdir /e5fs
chmod 755 /e5fs
chown root:root /e5fs
mkdir -p /e5fs/lfp_print_files
chmod 2775 /e5fs/lfp_print_files
chown e5fs:e5fsadmin /e5fs/lfp_print_files

#Create /batenvp1rep/archive dir, permissions & ownership
mkdir /batenvp1rep
chmod 755 /batenvp1rep
chown root:root /batenvp1rep
mkdir -p /batenvp1rep/archive
chmod 777 /batenvp1rep/archive
chown batenvp1rep:batch /batenvp1rep/archive

#Copy /etc/fstab share info from vault
cat <<EOF >> /etc/fstab
${BULK_GATEWAY_INPUTS}
EOF

#Mount shares
mount -a
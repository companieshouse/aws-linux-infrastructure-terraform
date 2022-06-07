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
groupadd -g 223800283 bankrupt
groupadd -g 223800274 bulk-staging
groupadd -g 1012200045 servnow

#Create Users
useradd -m -u 3651 batenvp1 -g batch
useradd -m -u 3653 batenvp1rep -g batch
useradd -m -u 223800273 bulk-live -g bulk-live -G e5fsadmin,csi,batch
useradd -m -u 223800210 gateway -g gateway -G e5fsadmin,csi,batch
useradd -u 1012200011 e5fs -g e5fs -G e5fsadmin
useradd -u 223800283 bankrupt -g bankrupt -G e5fsadmin,csi
useradd -u 223800274 bulk-staging -g bulk-staging -G e5fsadmin,csi
useradd -u 1012200045 servnow -g servnow

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

#Copy Github deploy key from vault
touch /root/.ssh/id_ed25519
chmod 600 /root/.ssh/id_ed25519
cat <<EOF >> /root/.ssh/id_ed25519
${GITHUB_DEPLOY_KEY}
EOF

#Script that copies deployment scripts from Git repo
touch /root/script_deploy.sh
chmod 755 /root/script_deploy.sh
cat <<EOF >> /root/script_deploy.sh
#!/bin/bash
#Script to clone deploy scripts from GitHub repo and copy to various locations

#Clone from GitHub repo
pushd /tmp
GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" git clone git@github.com:companieshouse/chips-service-admin.git
chmod +x /tmp/chips-service-admin/scripts/bulk-outputs/bootstrap.sh
/tmp/chips-service-admin/scripts/bulk-outputs/bootstrap.sh

EOF

#Copy /etc/fstab share info from vault
cat <<EOF >> /etc/fstab
${BULK_GATEWAY_INPUTS}
EOF

#Mount shares
mount -a

#Install Malix
yum install -y mailx

#Configure postfix to use AWS Shared Services mail relay
sed -i 's/#mydomain = domain.tld/mydomain = companieshouse.gov.uk/g' /etc/postfix/main.cf
sed -i 's/#relayhost = $mydomain/relayhost = smtp-outbound.sharedservices.aws.internal/g' /etc/postfix/main.cf
systemctl restart postfix

#Allow user to use cron
echo bulk-live >> /etc/cron.allow
echo gateway >> /etc/cron.allow

#Setup SSH keys
mkdir -p /home/gateway/.ssh/
chown gateway:gateway /home/gateway/.ssh/
chmod 700 /home/gateway/.ssh/
touch /home/gateway/.ssh/id_e5ftp_rsa
touch /home/gateway/.ssh/id_e5ftp_rsa.pub
touch /home/gateway/.ssh/id_rsa
touch /home/gateway/.ssh/id_rsa.pub
chown gateway:gateway /home/gateway/.ssh/id_e5ftp_rsa
chown gateway:gateway /home/gateway/.ssh/id_e5ftp_rsa.pub
chown gateway:gateway /home/gateway/.ssh/id_rsa
chown gateway:gateway /home/gateway/.ssh/id_rsa.pub
chmod 600 /home/gateway/.ssh/id_e5ftp_rsa
chmod 600 /home/gateway/.ssh/id_e5ftp_rsa.pub
chmod 600 /home/gateway/.ssh/id_rsa
chmod 600 /home/gateway/.ssh/id_rsa.pub
cat <<EOF >> /home/gateway/.ssh/id_e5ftp_rsa
${E5_SSH_KEY}
EOF
cat <<EOF >> /home/gateway/.ssh/id_e5ftp_rsa.pub
${E5_SSH_KEY_PUB}
EOF
cat <<EOF >> /home/gateway/.ssh/id_rsa
${GATEWAY_SSH_KEY}
EOF
cat <<EOF >> /home/gateway/.ssh/id_rsa.pub
${GATEWAY_SSH_KEY_PUB}
EOF

#Setup vault sourced environment variables
touch /etc/profile.d/vault_env.sh
chmod 644 /etc/profile.d/vault_env.sh
cat <<EOF >> /etc/profile.d/vault_env.sh
BULKLIVE_S3_KMS_KEY="${BULKLIVE_KMS_KEY}"
export BULKLIVE_S3_KMS_KEY
EOF

#Call script_deploy
/root/script_deploy.sh

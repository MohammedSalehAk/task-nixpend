#!/bin/bash

#######################################
# Hardening script for CentOS
#######################################

# Step 1: Document the host information
echo -e "\e[33mDocumenting host information...\e[0m"
echo "Hostname: $(hostname)"
echo "IP Address: $(hostname -I)"
echo "Operating System: $(cat /etc/centos-releasen)"

# Step 2: BIOS protection
echo -e "\e[33mEnabling BIOS protection...\e[0m"
dmidecode -t 0 | grep -i "security status: enabled" || echo "BIOS protection not enabled"

# Step 3: Remove unnecessary packages
sudo yum remove -y vim-minimal

# Step 4: Update the system
sudo yum update -y

# Step 5: Check the installed packages
echo -e "\e[33mChecking installed packages...\e[0m"
yum list installed

# Step 6: Check for open ports
echo -e "\e[33mChecking for open ports...\e[0m"
netstat -tulnp

# Step 7: Secure SSH
echo -e "\e[33mSecuring SSH...\e[0m"
sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/^PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
systemctl restart sshd

# Step 8: Set strong password policies
sudo sed -i 's/password    requisite     pam_cracklib.so /password    requisite     pam_cracklib.so minlen=12 ucredit=-1 lcredit=-2 dcredit=-1 ocredit=-1/g' /etc/pam.d/system-auth
sudo sed -i 's/password    \[success=1 default=ignore\]     pam_unix.so obscure use_authtok try_first_pass sha512/password    [success=1 default=ignore]     pam_unix.so obscure use_authtok try_first_pass sha512 remember=5/g' /etc/pam.d/system-auth


# Step 9: Permissions and verifications
echo -e "\e[33mPerforming permissions and verifications...\e[0m"
chmod 644 /etc/passwd /etc/group /etc/shadow /etc/gshadow
chown root:root /etc/passwd /etc/shadow
chown root:shadow /etc/shadow
chown root:root /etc/group /etc/gshadow
chown root:shadow /etc/gshadow
chown root:root /boot/grub2/grub.cfg
chmod og-rwx /boot/grub2/grub.cfg
chmod 700 /root

# Step 10: Remove unnecessary services
echo -e "\e[33mRemoving unnecessary services...\e[0m"
systemctl disable avahi-daemon.service
systemctl disable cups.service
systemctl disable dhcpd.service
systemctl disable slapd.service
systemctl disable named.service
systemctl disable xinetd.service
systemctl disable avahi-daemon.service

# Step 11: Check for security on key files
echo -e "\e[33mChecking security on key files...\e[0m"
chmod 600 /root/.ssh/authorized_keys
chmod 700 /root/.ssh/
chown root:root /root/.ssh/
ls -al /root/.ssh

# Step 12: Remote access and SSH basic settings
echo -e "\e[33mSetting up remote access and SSH basic settings...\e[0m"
sed -i 's/^#LogLevel.*/LogLevel VERBOSE/g' /etc/ssh/sshd_config
sed -i 's/^#MaxAuthTries.*/MaxAuthTries 4/g' /etc/ssh/sshd_config
systemctl restart sshd

# Step 13: Configure the firewall
sudo firewall-cmd --set-default-zone=drop
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --reload

# Step 14: Disable unused network protocols
sudo echo 'install dccp /bin/true' >> /etc/modprobe.d/hardening.conf
sudo echo 'install sctp /bin/true' >> /etc/modprobe.d/hardening.conf
sudo systemctl disable rdma
sudo systemctl disable ip6tables

# Step 15: Enable auditd for system auditing
sudo yum install -y audit
sudo systemctl enable auditd
sudo systemctl start auditd

echo -e "\e[32mHardening complete!\e[0m"
#!/bin/bash

#######################################
# Hardening script for Ubuntu
#######################################

# Step 1: Remove unnecessary packages
sudo apt-get remove -y vim-tiny

# Step 2: Update the system
sudo apt-get update
sudo apt-get upgrade -y

# Step 3: Hard disk encryption
echo -e "\e[33mStep 3: Hard disk encryption\e[0m"
echo "Checking if hard disk encryption is enabled..."
if [ -d /etc/luks ]; then
  echo "Hard disk encryption is enabled"
else
  echo "Hard disk encryption is not enabled"
fi
echo ""

# Step 4: Lock the boot directory
echo -e "\e[33mSstep 5: Lock the boot directory\e[0m"
echo "Locking the boot directory..."
sudo chmod 700 /boot

# Step 5: Disable root login via SSH
sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
sudo systemctl restart sshd

# Step 6: Check the installed packages
echo -e "\e[33mStep 8: Checking the installed packages\e[0m"
dpkg --get-selections | grep -v deinstall

# Step 7: Secure SSH
echo -e "\e[33mStep 10: Securing SSH\e[0m"
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sudo systemctl restart sshd


# Step 8: Manage password policies
echo -e "\e[33mStep 13: Managing password policies\e[0m"
echo "Modifying the password policies..."
sudo sed -i 's/PASS_MAX_DAYS\t99999/PASS_MAX_DAYS\t90/g' /etc/login.defs
sudo sed -i 's/PASS_MIN_DAYS\t0/PASS_MIN_DAYS\t7/g' /etc/login.defs
sudo sed -i 's/PASS_WARN_AGE\t7/PASS_WARN_AGE\t14/g' /etc/login.defs

# Step 9: Permissions and verifications
echo -e "\e[33mStep 14: Permissions and verifications\e[0m"
echo "Setting the correct permissions on sensitive files..."
sudo chmod 700 /etc/shadow /etc/gshadow /etc/passwd /etc/group
sudo chmod 600 /boot/grub/grub.cfg
sudo chmod 644 /etc/fstab /etc/hosts /etc/hostname /etc/timezone /etc/bash.bashrc
echo "Verifying the integrity of system files..."
sudo debsums -c

# Step 10: Configure the firewall
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw enable

# Step 11: Check for security on key files
echo -e "\e[33mStep 17: Checking for security on key files\e[0m"
echo "Checking for security on key files..."
sudo find /etc/ssh -type f -name 'ssh_host_*_key' -exec chmod 600 {} \;

# Step 12: Limit root access using SUDO
echo -e "\e[33mStep 18: Limiting root access using SUDO\e[0m"
echo "Limiting root access using SUDO..."
sudo apt-get install sudo -y
sudo groupadd admin
sudo usermod -a -
sudo sed -i 's/%sudo\tALL=(ALL:ALL) ALL/%admin\tALL=(ALL:ALL) ALL/g' /etc/sudoers

# Step 13: Remote access and SSH basic settings
echo -e "\e[33mStep 20: Remote access and SSH basic settings\e[0m"
echo "Disabling root login over SSH..."
sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
echo "Disabling password authentication over SSH..."
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
echo "Disabling X11 forwarding over SSH..."
sudo sed -i 's/X11Forwarding yes/X11Forwarding no/g' /etc/ssh/sshd_config
echo "Reloading the SSH service..."
sudo systemctl reload sshd

# Step 14: Disable unused network protocols
sudo sed -i 's/^hosts:.*$/hosts:      files dns/g' /etc/nsswitch.conf
sudo echo 'install dccp /bin/true' >> /etc/modprobe.d/hardening.conf
sudo echo 'install sctp /bin/true' >> /etc/modprobe.d/hardening.conf

# Step 15: Monitor system logs
echo -e "\e[33mStep 27: Monitoring system logs\e[0m"
echo "Installing logwatch for system log monitoring..."
sudo apt-get install logwatch -y

echo -e "\e[32mHardening complete!\e[0m"

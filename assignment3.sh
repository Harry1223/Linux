#!/bin/bash

# Describeing target machine variables.
TARGET1="remoteadmin@172.16.1.10"
TARGET2="remoteadmin@172.16.1.11"

# Function to run commands
Commands_to_Run() {
    ssh $1 "$2"
}

# Target 1 configuration

#setting-up hostname to loghost of TARGET1
Commands_to_Run $TARGET1 "sudo hostnamectl set-hostname loghost"

# updating etc/hosts
Commands_to_Run $TARGET1 "sudo awk -i inplace '/172.16.1.10[[:space:]]target1/{$2=\"loghost\"}1' /etc/hosts"
Commands_to_Run $TARGET1 "sudo sed -i 's/172.16.1.10\tloghost/172.16.1.4\twebhost/' /etc/hosts"

#installing and configureung apt and ufw for target2
Commands_to_Run $TARGET1 "sudo apt-get update"
Commands_to_Run $TARGET1 "sudo apt-get install -y ufw"
Commands_to_Run $TARGET1 "sudo ufw allow from 172.16.1.0/24 to any port 514 proto udp"
Commands_to_Run $TARGET1 "sudo sed -i '/imudp/s/^#//' /etc/rsyslog.conf && sudo systemctl restart rsyslog"


# Target 2 configuration

#Set the hostname of TARGET2 to webhost
Commands_to_Run $TARGET2 "sudo sed -i 's/127.0.1.1.*/127.0.1.1\twebhost/g' /etc/hosts && sudo hostnamectl set-hostname webhost"

#updating etc/hosts 
Commands_to_Run $TARGET2 "sudo awk -i inplace '/172.16.1.11[[:space:]]target2/{$2=\"webhost\"}1' /etc/hosts"
Commands_to_Run $TARGET2 "sudo sed -i 's/172.16.1.11\twebhost/172.16.1.3\tloghost/' /etc/hosts"

#installing and configureung apt and ufw for target2
Commands_to_Run $TARGET2 "sudo apt-get update"
Commands_to_Run $TARGET2 "sudo apt-get install -y ufw apache2"
Commands_to_Run $TARGET2 "sudo ufw allow 80/tcp"
Commands_to_Run $TARGET2 "sudo sh -c 'echo \"*.* @loghost\" >> /etc/rsyslog.conf'"
Commands_to_Run $TARGET2 "sudo systemctl restart rsyslog"

# Updateing NMS hosts file with IPaddress 
printf "172.16.1.3\tloghost\n172.16.1.4\twebhost\n" | sudo tee -a /etc/hosts

# Check configurations
if firefox http://webhost &>/dev/null; then
    if ssh remoteadmin@loghost grep webhost /var/log/syslog &>/dev/null; then
        echo "____The configuration change completed successfully____"
    else
        echo "____Failed to download webhost logs from loghost____"
    fi
else
    echo "____The default Apache page could not be received from webhost____"
fi

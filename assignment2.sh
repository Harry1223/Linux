#!/bin/bash

# Function to configurtaion of  network file
function network_configuration {
    echo "____Configuring the Networks___"
    
    network_file="/etc/netplan/01-netcfg.yaml"
    target_ip="192.168.16.21/24"

#cheaking the  ip is configured
    if awk -F ': ' '/addresses:/ {print $2}' "$network_file" | grep -q "$target_ip"; then
        echo "____Network is already configured successfully____"
    else
#network configuration by using netplan
        netplan_config="network:
  version: 2
  ethernets:
    eth0:
      addresses: $target_ip
      gateway4: 192.168.16.1
      nameservers:
        addresses: [192.168.16.1]
        search: [home.arpa, localdomain]"

        echo "$netplan_config" | sudo tee "$network_file" > /dev/null
        sudo netplan apply
        echo "____Network configuration completed successfully____"
    fi
}

#function to install and update the software
function installing_softwares {
    echo "____Installing and Updating Software____"


    software_list=("openssh-server" "apache2" "squid")

    # checking software and install if not already installed
    for software in "${software_list[@]}"; do
        if ! dpkg -l "$software" &>/dev/null; then
            echo "Installing $software____"
            sudo apt-get update
            sudo apt-get install -y "$software"
            echo "____$software installed successfully____"
        else
            echo "_____$software is already installed successfully___"
        fi
    done
}

# Function for the  configuration of  firewall rules
function firewall_rules_configuration {
    echo "___Configuring Firewall Rules___"

    ports=("22" "80" "443" "3128")

    # Checking if UFW  status is active
    if ! sudo ufw status | grep -q "Status: active"; then
        # Enable UFW
        sudo ufw --force enable
        echo "____UFW rules are now enabled___"
    fi

    # Allow ports through the firewall
    for port in "${ports[@]}"; do
        if sudo ufw status | grep -q "$port"; then
            echo "_____$port is already allowed____"
        else
            sudo ufw allow "$port"
            echo "Port $port allowed."
        fi
    done

    echo " ____All Firewall rules are configured successfully____"
}

# Function for the  createing of user accounts
function creating_users_accounts {
    echo "____Creating User Accounts___"

    accounts=("dennis" "aubrey" "captain" "snibbles" "brownie" "scooter" "sandy" "perrier" "cindy" "tiger" "yoda")

    for account in "${accounts[@]}"; do
        if id "$account" &>/dev/null; then
            echo "____The user $account already added____"
        else
            sudo useradd -m -s /bin/bash "$account"
            sudo mkdir -p "/home/$account/.ssh"
            sudo touch "/home/$account/.ssh/authorized_keys"
            
            # Adding dummy SSH keys for demonstration
            echo -e 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI' | sudo tee -a "/home/$account/.ssh/authorized_keys"

            sudo chown -R "$account:$account" "/home/$account/.ssh"
            sudo chmod 700 "/home/$account/.ssh"
            sudo chmod 600 "/home/$account/.ssh/authorized_keys"

            echo "___User $account created and configured successfully____"
            
            if [ "$account" == "dennis" ]; then
                sudo adduser "$account" sudo
            fi
        fi
    done
}

# Calling functions
network_configuration
installing_softwares
firewall_rules_configuration
creating_users_accounts

echo "_____All configurations are done successfully___"

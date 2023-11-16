#!/bin/bash

# Configuring the networks
function configuration_of_network {
    echo "____Configuring the Network____"

    if grep -q "192.168.16.21/24" /etc/netplan/01-netcfg.yaml; then
        echo "____Network is already updated____"
    else
        sed -i '/^.*eth0.*inet /s/^.*$/    addresses: [192.168.16.21\/24]\ngateway4: 192.168.16.1\nnameservers:\n    addresses: [192.168.16.1]\n    search: [home.arpa, localdomain]/' /etc/netplan/01-netcfg.yaml

        # Netplan configuration applying
        sudo netplan apply

        echo "____Network configuration updated successfully____"
    fi
}

# Installing or updating software
function software_installation {
    echo "____Installing and Updating the Software____"

    # Checking for openssh-server is installed successfully
    if ! dpkg -l | grep -q openssh-server; then
        sudo apt install -y openssh-server
        echo "THe openssh-server is installed successfully"
    else
        echo "___The openssh-server is already installed___"
    fi

    # Checking for apache2 is installed successfully
    if ! dpkg -l | grep -q apache2; then
        sudo apt install -y apache2
        echo "____Apache2 is installed successfully"
    else
        echo "____Apache2 already installed____"
    fi

    # Checking for squid is installed successfully
    if ! dpkg -l | grep -q squid; then
        sudo apt install -y squid
        echo "____Squid installed successfully____"
    else
        echo "____Squid already installed____"
    fi
}

# Configuring UFW firewall rules
function configuration_of_firewall {
    echo "____Configuring Firewall rules____"

    # Checking for UFW is already configured successfully
    if sudo ufw status | grep -q "Status: active"; then
        echo "____Firewall rules are already configured____"
    else
        # Configuring UFW firewall rules
        sudo ufw allow 22
        sudo ufw allow 80
        sudo ufw allow 443
        sudo ufw allow 3128

        echo "____Firewall rules configured and enabled successfully____"
    fi
}

# Creating and adding user accounts
function creating_user_accounts {
    echo "____Creating the User Accounts____"

    users=("dennis" "aubrey" "captain" "snibbles" "brownie" "scooter" "sandy" "perrier" "cindy" "tiger" "yoda")

    for user in "${users[@]}"; do
        # Checking if the user exists or not
        if id "$user" &>/dev/null; then
            echo "____The user $user already added____"
        else
            sudo useradd -m -s /bin/bash "$user"
            sudo mkdir -p /home/$user/.ssh
            sudo touch /home/$user/.ssh/authorized_keys

            # Adding ssh keys for rsa and ed25519
            echo -e 'ssh-rsa cHco74vNhnOtn3X18t0qUxUCPF/dJBGFrD2bZcpVC+g student@student-virtual-machine' | sudo tee -a /home/$user/.ssh/authorized_keys
            echo -e 'ssh-AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm' | sudo tee -a /home/$user/.ssh/authorized_keys

            # Setting up ownership and permissions
            sudo chown -R $user:$user /home/$user/.ssh
            sudo chmod 700 /home/$user/.ssh
            sudo chmod 600 /home/$user/.ssh/authorized_keys

            echo "____User $user created and configured successfully____"

            # Granting sudo access to dennis user
            if [ "$user" == "dennis" ]; then
                sudo usermod -aG sudo dennis
            fi
        fi
    done
}

# Calling functions
configuration_of_network
software_installation
configuration_of_firewall
creating_user_accounts

echo "_______Configuration done Successfully_______"

#!/bin/bash

# Collecting Information about system
domain_name=$(hostname)
stm_os=$(source /etc/os-release && echo $PRETTY_NAME)
stm_uptime=$(uptime -p)

# Collecting Information about hardware
hdw_cpu_processor=$(grep 'model name' /proc/cpuinfo | uniq | awk -F': ' '{print $2}')
hdw_cpu_speed=$(lshw -c cpu | awk -F ':' '/capacity/ {print $2}' | sed 's/^[ \t]*//')
hdw_ram=$(free -h | awk '/Mem/ {print $2}')
hdw_disk_usage=$(lsblk -dno NAME,SIZE,MODEL | tail -n +2)
hdw_video_card=$(lspci | grep -i 'VGA' | awk -F': ' '{print $2}')


# Collecting Information about networking

ntw_FQDN=$(hostname -f)
ntw_IP_address=$(hostname -I | awk '{print $1}')
ntw_gateway=$(ip route | awk '/default/ {print $3}')
ntw_dns=$(cat /etc/resolv.conf | grep 'nameserver' | awk '{print $2}')

#collection informstion about interface

ntw_interfaces=$(ip -o link show | awk -F': ' '{print $2}')
ntw_make_model=$(lspci | grep -i 'network' | awk -F': ' '{print $2}')
ntw_ip_cidr=$(ip -o -4 addr show $net_interface | awk '/inet / {print $4}')

# Collecting Status of system
stm_users=$(who | awk '{print $1}' | sort -u | tr '\n' ',' | sed 's/,$//')
stm_disk_space=$(df -h | awk '{print $1,$4}' | tail -n +2)
stm_process_count=$(ps aux | wc -l)
stm_load_averages=$(uptime | awk -F': ' '{print $2}')
stm_memory_allocation=$(free -m)
stm_ports=$(netstat -tuln | awk '$6 == "LISTEN" {print $4}' | sort -u)
stm_ufw_rules=$(sudo cat /etc/ufw/user.rules)

# Printing the  information


echo "SYSTEM INFORMRION"
echo "-------------"
echo "Domain Name: $domain_name"
echo "OS: $stm_os"
echo "Uptime: $stm_uptime"
echo ""

#printion information anout hardware

echo "HARDWARE INFORMARION"
echo "--------------------"
echo "CPU processor: $hdw_cpu_processor"
echo "CPU Speed: $hdw_cpu_speed"
echo "RAM: $hdw_ram"
echo "Disk_useage: $hdw_disk_usage"
echo "Video Card: $hdw_video_card"
echo""
#printing information about networks 

echo "NETWORK INFORMATION"
echo "-------------------"
echo "FQDN: $ntw_FQDN"
echo "Host Address: $ntw_IP_address"
echo "Gateway IP address: $ntw_gateway"
echo "DNS Servers: $ntw_dns"
echo""
#pinrting information about  interface 

echo "INTERFACE INFORMARION"
echo "---------------------"
echo "Network Interfaces: $ntw_interfaces"
echo "Network Model Name: $ntw_make_model"
echo "IP address in CIDR format: $ntw_ip_cidr"
echo""

#printing information about system status  
echo "SYSTEM STATUS INFORMARION"
echo "-------------------------"
echo " Users: $stm_users"
echo "Disk Space: $stm_disk_space"
echo "Process Count: $stm_process_count"
echo "Load Averages: $stm_load_averages"
echo "Memory Allocation: $stm_memory_allocation"
echo "Network Ports: $stm_ports"
echo "UFW Rules: $stm_ufw_rules"


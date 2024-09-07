#!/bin/bash

# Check if two arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <IP Address> <Hostname>"
    exit 1
fi

# Assign arguments to variables
new_ip=$1
new_hostname=$2

# File to edit
hosts_file="/etc/hosts"

# Add Timestamp 
timestamp=$(date +"%Y%m%d-%H%M%S")

# Backup the hosts file before modification
cp $hosts_file "/home/crimson/OffSec/ProvingGrounds/Host_backup/etc_host-$timestamp.bak"

# Find the line number of the comment "# Add hostname"
line_num=$(grep -n '# Add hostname' $hosts_file | cut -d: -f1)

# Delete all lines after the "# Add hostname" comment
sed -i "${line_num},\$d" $hosts_file

# Remove existing entries with the same IP or hostname
sed -i "/$new_ip/d" $hosts_file
sed -i "/$new_hostname/d" $hosts_file

# Add the new IP address and hostname
echo -e "${new_ip}\t${new_hostname}" >> $hosts_file

echo "Hosts file updated successfully."

# Print out the contents of the /etc/hosts file
echo "Current contents of the /etc/hosts file:"
cat $hosts_file

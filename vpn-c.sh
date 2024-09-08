#!/bin/bash

# Folder containing the OpenVPN configuration files
VPN_DIR="/home/g0th3r/VPN"

# Output file for the tunnel IP address
OUTPUT_FILE="/home/g0th3r/Scripts/ip_tunnel.txt"

# Function to kill all OpenVPN tunnels and reset the output file
killall_tunnels() {
  sudo killall openvpn
  echo "🚫---VPN OFF---" > "$OUTPUT_FILE"
  chmod 666 "$OUTPUT_FILE"
  echo -e "\e[1;31mAll OpenVPN tunnels killed. $OUTPUT_FILE has been reset.\e[0m"
}

# Function to display the menu and get user choice
choose_vpn() {
  echo -e "\e[1;33m==================================================================\e[0m"
  echo -e "Select an option:\n"
  echo -e "\e[1;31m1. Kill all tunnels\e[0m"
  
  # Create an array of VPN files
  vpn_files=("$VPN_DIR"/*.ovpn)
  
  # Strip the directory and .ovpn extension from filenames for display
  vpn_names=()
  for vpn_file in "${vpn_files[@]}"; do
    vpn_names+=("$(basename "$vpn_file" .ovpn)")
  done

  # Colors array
  colors=(31 32 33 34 35 36)
  color_count=${#colors[@]} 

  # Display the menu options with filenames only (without .ovpn) in different colors and bold
  for i in "${!vpn_names[@]}"; do
    color="${colors[$((i % color_count))]}"
    echo -e "\e[1;${color}m$((i + 2)). ${vpn_names[$i]}\e[0m"
  done
  echo
  echo -e "\e[1;33m==================================================================\e[0m"
  
  # Read user input
  while true; do
    read -p "Enter the number of your choice: " selection
    if [[ $selection == 1 ]]; then
      killall_tunnels
      break
    elif [[ $selection =~ ^[2-9][0-9]*$ ]] && [ "$selection" -le $((${#vpn_names[@]} + 1)) ]; then
      vpn_name="${vpn_names[$((selection - 2))]}"
      vpn_path="$VPN_DIR/$vpn_name.ovpn"
      echo -e "\e[1;33m==================================================================\e[0m"
      echo "Connecting to $vpn_path..."

      sudo openvpn "$vpn_path" &> /dev/null &
      sleep 15  # Wait for the VPN connection to establish
      tun_interface=$(ip link show | grep -oP 'tun[0-9]+' | head -n 1)
      if [ -n "$tun_interface" ]; then
        ip_address=$(ip -o -4 addr list "$tun_interface" | awk '{print $4}' | cut -d/ -f1)
        echo -e "\e[1;32mSuccessfully created interface: \e[1;31m$tun_interface\e[0m with IP address: \e[1;31m$ip_address\e[0m"
        echo "🔱 $ip_address" > "$OUTPUT_FILE"
        echo -e "\e[1;33mTunnel IP address written to: \e[1;31m$OUTPUT_FILE\e[0m"
        chmod 666 $OUTPUT_FILE
        echo -e "\e[1;33m==================================================================\e[0m"
      else
        echo -e "\e[1;31mFailed to create a tun interface.\e[0m"
      fi
      break
    else
      echo "Invalid selection, please try again."
    fi
  done
}

# Display the menu
choose_vpn

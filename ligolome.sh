#!/bin/bash
# This Bash script sets up a tunnel interface named "ligolo" and configures a proxy server using the ligolo-proxy tool. It starts by cleaning up any existing "ligolo" interface before creating a new tunnel interface with tuntap. The script then waits for the tun0 interface to acquire an IP address, retrieves that IP using the get_tun0_ip function, and validates if it's successfully obtained. If successful, it launches the proxy on port 443, using the retrieved IP address. Finally, the script confirms that the tunnel and proxy setup is complete.

# Function to get IP address of tun0
get_tun0_ip() {
  ip -o -4 addr list tun0 | awk '{print $4}' | cut -d/ -f1
}

# Cleanup any existing ligolo interface
if ip link show ligolo > /dev/null 2>&1; then
  echo "Deleting existing ligolo interface..."
  sudo ip link delete ligolo
fi

# Prepare Tunnel Interface
echo "Creating tunnel interface..."
sudo ip tuntap add user $(whoami) mode tun ligolo

# Set the tunnel interface up
echo "Setting tunnel interface up..."
sudo ip link set ligolo up

# Wait for the tun0 interface to get an IP address
echo "Waiting for tun0 to get an IP address..."
sleep 5  # Adjust sleep time if necessary

# Get the IP address of tun0
TUN0_IP=$(get_tun0_ip)

if [ -z "$TUN0_IP" ]; then
  echo "Failed to get IP address of tun0"
  exit 1
fi

echo "IP address of tun0: $TUN0_IP"

# Setup Proxy on Attacker Machine
echo "Starting proxy with address $TUN0_IP..."
ligolo-proxy -laddr $TUN0_IP:443 -selfcert

echo "Tunnel and proxy setup complete."

#!/bin/bash

# Set variables from environment or use default values
REMOTE_USER="${REMOTE_USER}"
REMOTE_HOST="${REMOTE_HOST}"
SERVER_USER="${SERVER_USER}"
SERVER_IP="${SERVER_IP}"
MAC_ADDRESS="${MAC_ADDRESS}"

remote_check_or_wake() {
  server_ip=$1
  server_user=$2
  mac_address=$3

  if ! ping -c 1 -W 1 $server_ip >/dev/null 2>&1; then
    echo "Sending Wake on LAN signal to server..."
    sudo etherwake -i eth0 $mac_address

    echo "Waiting for server to wake up..."
    while true; do
      if ssh -q -o "ConnectTimeout=5" -o "StrictHostKeyChecking=no" "${server_user}@${server_ip}" "exit" 2>/dev/null; then
        echo "Server is up!"
        break
      else
        echo "Server is still starting up, retrying in 5 seconds..."
        sleep 5
      fi
    done
  else
    echo "Server is already up!"
  fi

  echo "Connecting to Manjaro Linux server..."
  if [[ "$tunnel" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    ssh -L $port:localhost:$port "${server_user}@${server_ip}"
  else
    ssh "${server_user}@${server_ip}"
  fi

}

read -p "Would you like to tunnel? [y/N]: " tunnel

if [[ "$tunnel" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  read -p "Specify the port to tunnel (default: 9090): " port
  port=${port:-9090}
  echo "Creating SSH tunnel to remote jump host..."
  ssh -f -N -L $port:localhost:$port "${REMOTE_USER}@${REMOTE_HOST}"
fi

ssh -t "${REMOTE_USER}@${REMOTE_HOST}" "$(declare -f remote_check_or_wake); remote_check_or_wake $SERVER_IP $SERVER_USER $MAC_ADDRESS"

# Step 5: Prompt user to shutdown the server
read -p "Do you want to shut down the server? (y/n): " shutdown_choice
if [ "$shutdown_choice" == "y" ]; then
  echo "Shutting down server..."
  ssh -t "${SERVER_USER}@${SERVER_IP}" "sudo shutdown now"
else
  echo "Not shutting down the server. Exiting."
fi

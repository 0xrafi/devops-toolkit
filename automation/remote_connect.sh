#!/bin/bash

# Set variables from environment or use default values
REMOTE_USER="${REMOTE_USER}"
REMOTE_HOST="${REMOTE_HOST}"
SERVER_USER="${SERVER_USER}"
SERVER_IP="${SERVER_IP}"
MAC_ADDRESS="${MAC_ADDRESS}"

is_server_up() {
  server_ip=$1

  if ! ping -c 1 -W 1 $server_ip >/dev/null 2>&1; then
    return 1
  else
    return 0
  fi
}

wake_server() {
  server_connection=$1
  mac_address=$2

  echo "Sending Wake on LAN signal to server..."
  sudo etherwake -i eth0 $mac_address

  echo "Waiting for server to wake up..."
  while true; do
    if ssh -q -o "ConnectTimeout=5" -o "StrictHostKeyChecking=no" "${server_connection}" "exit" 2>/dev/null; then
      echo "Server is up!"
      break
    else
      echo "Server is still starting up, retrying in 5 seconds..."
      sleep 5
    fi
  done
}

connect_to_server() {
  server_connection=$1
  tunnel=$2
  port=$3

  if [[ "$tunnel" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    ssh -L $port:localhost:$port "${server_connection}"
  else
    ssh "${server_connection}"
  fi
}

remote_shutdown() {
  server_connection=$1
  ssh "${server_connection}" "sudo shutdown now"
}

prompt_for_tunnel() {
  read -p "Would you like to tunnel? [y/N]: " tunnel

  if [[ "$tunnel" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    read -p "Specify the port to tunnel (default: 9090): " port
    port=${port:-9090}
  else
    port=0
  fi
  echo "$tunnel,$port"
}

main() {
  server_connection="${SERVER_USER}@${SERVER_IP}"
  IFS=',' read -ra tunnel_and_port <<<"$(prompt_for_tunnel)"
  tunnel="${tunnel_and_port[0]}"
  port="${tunnel_and_port[1]}"

  if [[ "$tunnel" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "Creating SSH tunnel to remote jump host..."
    ssh -f -N -L $port:localhost:$port "${REMOTE_USER}@${REMOTE_HOST}"
  fi

  if ! ssh -t "${REMOTE_USER}@${REMOTE_HOST}" "$(declare -f is_server_up); is_server_up '$server_connection'" >/dev/null 2>&1; then
    echo "Server is not up. Attempting to wake it up."
    ssh -t "${REMOTE_USER}@${REMOTE_HOST}" "$(declare -f wake_server); wake_server '$server_connection' $MAC_ADDRESS"
  else
    echo "Server is already up!"
  fi

  echo "Connecting to Manjaro Linux server..."
  ssh -t "${REMOTE_USER}@${REMOTE_HOST}" "$(declare -f connect_to_server); connect_to_server '$server_connection' '$tunnel' $port"

  read -p "Do you want to shut down the server? (y/n): " shutdown_choice
  if [ "$shutdown_choice" == "y" ]; then
    echo "Shutting down server..."
    ssh -t "${REMOTE_USER}@${REMOTE_HOST}" "$(declare -f remote_shutdown); remote_shutdown '$server_connection'"
  else
    echo "Not shutting down the server. Exiting."
  fi

}

main
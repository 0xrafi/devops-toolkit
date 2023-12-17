#!/bin/bash

#### NOTES, Dec 2023
# Am learning about 'ProxyJump' SSH config,
# which removes the need for complex command
# chaining and remote function execution

# constants
readonly INITIAL_WAIT_TIME=20
readonly SUBSEQUENT_WAIT_TIME=5

# Set variables from environment or default values
tunnel="no"
port=0

jumphost_user="${REMOTE_USER}"  
jumphost="${REMOTE_HOST}" # remote host is duck DNS RPi
jump_connection="${jumphost_user}@${jumphost}"

manjaro_user="${SERVER_USER}"
manjaro_ip="${SERVER_IP}" # local IP of Manjaro server
manjaro_connection="${manjaro_user}@${manjaro_ip}"

mac_address="${MAC_ADDRESS}" # local Mac address of Manjaro server

is_server_online() {
    if ssh -q "${jump_connection}" "ping -c 3 -W 3 $manjaro_ip" >/dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}

is_yes_response() {
  local response=$1
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    return 0
  else
    return 1
  fi
}

wake_up_server() {
  echo "Sending Wake on LAN signal to server..."
  ssh "${jump_connection}" "sudo etherwake -i eth0 ${mac_address}"
  echo "Waiting for server to wake up..."
  sleep $INITIAL_WAIT_TIME
  while true; do
    if ssh -q -o "ConnectTimeout=5" -o "StrictHostKeyChecking=no" "${manjaro_connection}" "exit" 2>/dev/null; then
      echo "Server is up!"
      break
    else
      echo "Server is still starting up, retrying in $SUBSEQUENT_WAIT_TIME seconds..."
      sleep $SUBSEQUENT_WAIT_TIME
    fi
  done
}

initiate_remote_shutdown() {
  echo "Initiating shutdown of the server..."
  ssh -A -t "${manjaro_connection}" "sudo shutdown now"
}

prompt_tunnel_config() {
  read -p "Would you like to tunnel? [y/N]: " tunnel_response
  if is_yes_response "$tunnel_response"; then
    tunnel="yes"
    while true; do
      read -p "Specify the port to tunnel (default: 9090): " port
      port=${port:-9090}
      if ! [[ $port =~ ^[0-9]+$ ]]; then
        echo "Error: Port must be a number. Please try again."
      else
        break
      fi
    done
  fi
}

check_and_wake_server() {
  if ! is_server_online; then
    echo "Server is not up. Attempting to wake it up."
    wake_up_server
  else
    echo "Server is already up!"
  fi
}

establish_manjaro_connection() {
  prompt_tunnel_config
  if is_yes_response "$tunnel"; then
    ssh -f -N -L $port:localhost:$port "${manjaro_connection}"
  else
    echo "Connecting to Manjaro Linux server..."
    ssh "${manjaro_connection}"
  fi
}

shutdown_server() {
  read -p "Do you want to shut down the server? (y/n): " shutdown_choice
  if is_yes_response "$shutdown_choice"; then
    echo "You may be prompted to enter the remote server's password for 'sudo' access."
    initiate_remote_shutdown
  else
    echo "Not shutting down the server. Exiting."
  fi
}

kill_port_listener() {
  if is_yes_response "$tunnel"; then
    echo "Killing the process locally that is listening on port $port..."
    echo "Enter password for local machine:"
    sudo kill $(sudo lsof -t -i:$port)
  fi
}

main() {
  check_and_wake_server
  establish_manjaro_connection
  shutdown_server
  kill_port_listener
}

main

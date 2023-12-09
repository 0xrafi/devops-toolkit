#!/bin/bash

#### NOTES, Dec 2023
# Am learning about 'ProxyJump' SSH config,
# which removes the need for complex command
# chaining and remote function execution

# constants
readonly INITIAL_WAIT_TIME=20
readonly SUBSEQUENT_WAIT_TIME=5

# Set variables from environment or use default values
# these are both the same
remote_user="${REMOTE_USER}" 
server_user="${SERVER_USER}"
 
remote_host="${REMOTE_HOST}" # remote host is duck DNS RPi
server_ip="${SERVER_IP}" # local IP of Manjaro server
mac_address="${MAC_ADDRESS}" # local Mac address of Manjaro server
# jump_connection="${remote_user}@${remote_host}"
server_connection="${server_user}@${server_ip}"

is_server_online() {
    if ssh -q "${remote_user}@${remote_host}" "ping -c 3 -W 3 $server_ip" >/dev/null 2>&1; then
    return 1
  else
    return 0
  fi
}

is_yes_response() {
  local response=$1
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    return 0  # Success, response is 'yes'
  else
    return 1  # Failure, response is not 'yes'
  fi
}

wake_up_server() {
  echo "Sending Wake on LAN signal to server..."
  ssh "${remote_user}@${remote_host}" "sudo etherwake -i eth0 ${mac_address}"

  echo "Waiting for server to wake up..."

  sleep $INITIAL_WAIT_TIME

  while true; do
    if ssh -q -o "ConnectTimeout=5" -o "StrictHostKeyChecking=no" "${server_connection}" "exit" 2>/dev/null; then
      echo "Server is up!"
      break
    else
      echo "Server is still starting up, retrying in $SUBSEQUENT_WAIT_TIME seconds..."
      sleep $SUBSEQUENT_WAIT_TIME
    fi
  done
}

establish_server_connection() {
  tunnel=$1
  port=$2
  if is_yes_response "$tunnel"; then
    ssh -f -N -L $port:localhost:$port "${server_connection}"
  else
    echo "Connecting to Manjaro Linux server..."
    ssh "${server_connection}"
  fi
}

initiate_remote_shutdown() {
  echo "Initiating shutdown of the server..."
  ssh -A -t "${server_connection}" "sudo shutdown now"
}

establish_ssh_tunnel() {
  local tunnel=$1
  local port=$2
  if is_yes_response "$tunnel"; then
    log_info "Creating SSH tunnel to remote jump host..."
    ssh -f -N -L $port:localhost:$port "${remote_user}@${remote_host}"
  fi
}

prompt_tunnel_config() {
  read -p "Would you like to tunnel? [y/N]: " tunnel
  if is_yes_response "$tunnel"; then
    while true; do
      read -p "Specify the port to tunnel (default: 9090): " port
      port=${port:-9090}
      if ! [[ $port =~ ^[0-9]+$ ]]; then
        echo "Error: Port must be a number. Please try again."
      else
        break
      fi
    done
  else
    port=0
  fi
  echo "$tunnel,$port"
}

handle_ssh_tunnel_setup() {
  IFS=',' read -ra tunnel_and_port <<<"$(prompt_tunnel_config)"
  tunnel="${tunnel_and_port[0]}"
  port="${tunnel_and_port[1]}"

  establish_ssh_tunnel "${tunnel}" "${port}"
}

check_and_wake_server() {
  
}

main() {

  handle_ssh_tunnel_setup

  if ! is_server_online; then
    echo "Server is not up. Attempting to wake it up."
    wake_up_server
  else
    echo "Server is already up!"
  fi

  establish_server_connection "${tunnel}" "${port}"

  read -p "Do you want to shut down the server? (y/n): " shutdown_choice
  if is_yes_response "$shutdown_choice"; then
    echo "You may be prompted to enter the remote server's password for 'sudo' access."
    initiate_remote_shutdown
  else
    echo "Not shutting down the server. Exiting."
  fi

  if is_yes_response "$tunnel"; then
    echo "Killing the process locally that is listening on port $port..."
    echo "Enter password for local machine:"
    sudo kill $(sudo lsof -t -i:$port)
  fi
}

main

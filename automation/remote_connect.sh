#!/bin/bash

# constants
readonly INITIAL_WAIT_TIME=20
readonly SUBSEQUENT_WAIT_TIME=5

# Set variables from environment or use default values
remote_user="${REMOTE_USER}"
remote_host="${REMOTE_HOST}"
server_user="${SERVER_USER}"
server_ip="${SERVER_IP}"
mac_address="${MAC_ADDRESS}"

is_server_online() {
  server_ip=$1
  if ! ping -c 3 -W 3 $server_ip >/dev/null 2>&1; then
    return 1
  else
    return 0
  fi
}

wake_up_server() {
  server_connection=$1
  mac_address=$2

  echo "Sending Wake on LAN signal to server..."
  sudo etherwake -i eth0 $mac_address

  echo "Waiting for server to wake up..."

  sleep $INITIAL_WAIT_TIME

  while true; do
    if ssh -q -o "ConnectTimeout=5" -o "StrictHostKeyChecking=no" "${server_connection}" "exit" 2>/dev/null; then
      echo "Server is up!"
      break
    else
      echo "Server is still starting up, retrying in $SUBSEQUENT_WAIT_TIME seconds..."
      echo "INITIAL_WAIT_TIME is set to: $INITIAL_WAIT_TIME"
      echo "SUBSEQUENT_WAIT_TIME is set to: $SUBSEQUENT_WAIT_TIME"
      sleep $SUBSEQUENT_WAIT_TIME
    fi
  done
}

establish_server_connection() {
  server_connection=$1
  tunnel=$2
  port=$3

  if [[ "$tunnel" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    ssh -L $port:localhost:$port "${server_connection}"
  else
    ssh "${server_connection}"
  fi
}

initiate_remote_shutdown() {
  server_connection=$1
  ssh -A -t "${server_connection}" "sudo shutdown now"
}



establish_ssh_tunnel() {
  local tunnel=$1
  local port=$2
  if [[ "$tunnel" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    log_info "Creating SSH tunnel to remote jump host..."
    ssh -f -N -L $port:localhost:$port "${remote_user}@${remote_host}"
  fi
}

prompt_tunnel_config() {
  read -p "Would you like to tunnel? [y/N]: " tunnel
  if [[ "$tunnel" =~ ^([yY][eE][sS]|[yY])$ ]]; then
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

main() {
  server_connection="${server_user}@${server_ip}"
  IFS=',' read -ra tunnel_and_port <<<"$(prompt_tunnel_config)"
  tunnel="${tunnel_and_port[0]}"
  port="${tunnel_and_port[1]}"

  if [[ "$tunnel" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "Creating SSH tunnel to remote jump host..."
    ssh -f -N -L $port:localhost:$port "${remote_user}@${remote_host}"
  fi

  if ! ssh -t "${remote_user}@${remote_host}" "$(declare -f is_server_online); is_server_online '$server_ip'" >/dev/null 2>&1; then
    echo "Server is not up. Attempting to wake it up."
    ssh -t "${remote_user}@${remote_host}" "$(declare -f wake_up_server); wake_up_server '$server_connection' $mac_address"
  else
    echo "Server is already up!"
  fi

  echo "Connecting to Manjaro Linux server..."
  ssh -t "${remote_user}@${remote_host}" "$(declare -f establish_server_connection); establish_server_connection '$server_connection' '$tunnel' $port"

  read -p "Do you want to shut down the server? (y/n): " shutdown_choice
  if [ "$shutdown_choice" == "y" ]; then
    echo "Shutting down server..."
    echo "Enter password for remote:"
    ssh -A -t "${remote_user}@${remote_host}" "$(declare -f initiate_remote_shutdown); initiate_remote_shutdown '$server_connection'"
    echo "Initiated shutdown."
  else
    echo "Not shutting down the server. Exiting."
  fi

  if [[ "$tunnel" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "Killing the process locally that is listening on port $port..."
    echo "Enter password for local machine:"
    sudo kill $(sudo lsof -t -i:$port)
  fi
}

main

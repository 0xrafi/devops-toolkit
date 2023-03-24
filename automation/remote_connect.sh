#!/bin/bash

# Set variables from environment or use default values
REMOTE_USER="${REMOTE_USER}"
REMOTE_HOST="${REMOTE_HOST}"
SERVER_USER="${SERVER_USER}"
SERVER_IP="${SERVER_IP}"
MAC_ADDRESS="${MAC_ADDRESS}"

# Step 1: SSH tunnel to remote jump host
echo "Creating SSH tunnel to remote jump host..."
ssh -f -N -L 9090:localhost:9090 "${REMOTE_USER}@${REMOTE_HOST}"

# Step 2: Wake on LAN server
echo "Sending Wake on LAN signal to server..."
ssh "${REMOTE_USER}@${REMOTE_HOST}" "sudo etherwake -i eth0 $MAC_ADDRESS"

# Step 3: Wait for server to wake up and keep trying until successful
echo "Waiting for server to wake up..."
while true; do
  if ssh -q -o "ConnectTimeout=5" -o "StrictHostKeyChecking=no" "${SERVER_USER}@${SERVER_IP}" "exit" 2> /dev/null; then
    echo "Server is up!"
    break
  else
    echo "Server is still starting up, retrying in 5 seconds..."
    sleep 5
  fi
done

# Step 4: SSH into server
echo "Connecting to Manjaro Linux server..."
ssh -L 9090:localhost:9090 "${SERVER_USER}@${SERVER_IP}"

# Step 5: Shutdown server after exiting from SSH
echo "Shutting down server..."
ssh "${SERVER_USER}@${SERVER_IP}" "sudo shutdown now"


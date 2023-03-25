# Automation

In this folder, I've collected some scripts that help me automate various aspects of my workflow, making it more efficient and less error-prone. For now, I've added a script that automates connecting to my remote Manjaro server via a Raspberry Pi jump host.

## Scripts

### Remote Connect (`remote_connect.sh`)

This script has been a lifesaver for me! It automates the process of connecting to my remote Manjaro server via a Raspberry Pi jump host. It sets up an SSH tunnel, sends a Wake-on-LAN signal to the server, waits for it to start, and then establishes an SSH connection. Once I'm done and exit the SSH session, the server is automatically shut down.

#### Usage

1. Set the necessary environment variables or modify the script to include your credentials, server details, and MAC address.
2. Make the script executable: `chmod +x remote_connect.sh`
3. Run the script: `./remote_connect.sh`

#### Dependencies

- `etherwake`: Required for sending Wake-on-LAN signals. Install on the jump host if not already present.

As I create more automation scripts, I'll add them to this folder and update the usage instructions in the respective script files.


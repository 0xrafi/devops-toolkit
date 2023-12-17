# Automation
## Scripts

### Remote Connect (`remote_connect.sh`)

This script automates the process of connecting to my remote Manjaro server via a Raspberry Pi jump host. It sets up an SSH tunnel, sends a Wake-on-LAN signal to the server, waits for it to start, and then establishes an SSH connection. After closing the session, it asks if you'd like to shutdown.

NOTES, Dec 2023
I learned about 'ProxyJump' in the SSH config file,
which removed the need for complex command chaining and remote function execution. I don't have to set up an SSH tunnel beforehand + this script is way more secure.

#### Dependencies

- `etherwake`: Required for sending Wake-on-LAN signals. Install on the jump host if not already present.


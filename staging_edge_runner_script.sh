#!/bin/sh

# Check if telnet is installed
if ! command -v telnet &>/dev/null; then
    echo "Error: telnet is not installed. Please install it and try again."
    exit 1
fi

# Verify Connection to staging server before trying to run docker
SERVER="eu1.staging.edge.xyte.io"
PORT=443

if echo "quit" | telnet "$SERVER" "$PORT" 2>/dev/null | grep -q "Connected"; then
    echo "Connection successful"
else
    echo "Failed to connect to $SERVER on port $PORT."
    exit 1
fi

# Start the Docker container (suppress stdout)
docker run -d --privileged --network host --pull always --restart always -v ./edge_data:/xyte/edge_data --name xyte_edge xytetech/xyte_edge:staging > /dev/null

# proxy name file (created by container)
file="./edge_data/proxy_name.txt"

# Wait for the file to exist (for the first run it might not exist because it is created by the containers first run)
while [ ! -f "$file" ]; do
  sleep 1  # Sleep for 1 second before checking again
done

# Once the file exists, Read the content of the file into a variable
file_content=$(cat "$file")

# Print proxy name
echo "Proxy Name: $file_content"

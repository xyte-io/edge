# Check if telnet is installed
if ! command -v telnet &>/dev/null; then
    echo "Error: telnet is not installed. Please install it and try again."
    exit 1
fi

# Check if docker is installed
if ! command -v docker &>/dev/null; then
    echo "Error: docker is not installed. Please install it and try again."
    exit 1
fi


# Create edge_data directory if it doesn't exist
mkdir -p edge_data

# Check if edge_data directory is writable (we need to create files and share them with host for persistance through restarts)
if [ -w edge_data ]; then
  echo "The current user has write permissions to the 'edge_data' directory."
else
  echo "No write permission to 'edge_data'. Attempting to add write permission..."

  # Try to change permissions to allow the user to write
  chmod u+w edge_data 2>/dev/null

  # Check again
  if [ -w edge_data ]; then
    echo "Write permission successfully added."
  else
    echo "Failed to add write permission. You may need to run this script with elevated privileges (e.g., using sudo)."
    exit 1
  fi
fi

# Verify Connection to the production server before trying to run docker
SERVER="eu1.staging.edge.xyte.io"
PORT=443

if echo "quit" | telnet "$SERVER" "$PORT" 2>/dev/null | grep -q "Connected"; then
    echo "Connection successful"
else
    echo "Failed to connect to $SERVER on port $PORT."
    exit 1
fi

# Start the Docker container (suppress stdout)
docker run -d --privileged --network host --pull always --restart always -v $(pwd)/edge_data:/xyte/edge_data --name xyte_edge xytetech/xyte_edge:staging-stable-latest > /dev/null

# proxy name file (created by container)
file="$(pwd)/edge_data/proxy_name.txt"

# Wait for the file to exist (for the first run it might not exist because it is created by the containers first run)
while [ ! -f "$file" ]; do
  sleep 1  # Sleep for 1 second before checking again
done

# Once the file exists, Read the content of the file into a variable
file_content=$(cat "$file")

# Print proxy name
echo "

Proxy Name: $file_content
"

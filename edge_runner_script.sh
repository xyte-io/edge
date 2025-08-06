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

# Verify Connection to the production server before trying to run docker
SERVER="eu1.staging.edge.xyte.io"
PORT=443

if echo "quit" | telnet "$SERVER" "$PORT" 2>/dev/null | grep -q "Connected"; then
    echo "Connection successful"
else
    echo "Failed to connect to $SERVER on port $PORT."
    exit 1
fi

# Remove version tag files if they exist. This way we will always pull the latest version.
for f in "$(pwd)/edge_data/backup_version_tag.txt" "$(pwd)/edge_data/version_tag.txt"; do
  if [ -f "$f" ]; then
    rm -f "$f"
  fi
done

# Start the Docker container (suppress stdout)
docker run -d --privileged --network host --pull always --restart always -v $(pwd)/edge_data:/xyte/edge_data --name xyte_edge xytetech/xyte_edge:staging-stable-latest > /dev/null

# proxy name file (created by container)
file="$(pwd)/edge_data/proxy_name.txt"

echo "
Waiting for the Edge ID to be generated. This might take up to 90 seconds..."


# Wait for the file to exist, but no longer than 90 seconds
timeout=90
elapsed=0
while [ ! -f "$file" ] && [ $elapsed -lt $timeout ]; do
  sleep 1
  elapsed=$((elapsed + 1))
done

# If file still does not exist after timeout, exit with prompt
if [ ! -f "$file" ]; then
  echo "Unable to print Edge ID, please verify Edge is running using 'docker ps' and if so find Edge id using 'cat ./edge_data/proxy_name.txt'"
  exit 1
fi

# Once the file exists, Read the content of the file into a variable
file_content=$(cat "$file")

# Print proxy name
echo "

Edge ID: $file_content
To claim this Edge, please visit https://app.xyte.io/edges
"

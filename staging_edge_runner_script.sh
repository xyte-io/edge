#!/bin/sh

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

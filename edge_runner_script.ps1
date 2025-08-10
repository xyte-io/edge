# Check if Docker is installed
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "Error: Docker is not installed. Please install it and try again."
    exit 1
}

# Server and port
$server = "eu1.staging.edge.xyte.io"
$port = 443

# Test TCP connection to server
try {
    $tcpClient = New-Object System.Net.Sockets.TcpClient
    $tcpClient.Connect($server, $port)
    Write-Host "Connection successful"
    $tcpClient.Close()
} catch {
    Write-Host "Failed to connect to $server on port $port."
    exit 1
}

# Remove version tag files if they exist
$backupTag = Join-Path $PWD.Path "edge_data\backup_version_tag.txt"
$versionTag = Join-Path $PWD.Path "edge_data\version_tag.txt"
foreach ($f in @($backupTag, $versionTag)) {
    if (Test-Path $f) {
        Remove-Item $f -Force
    }
}

# Start the Docker container
$edgeDataPath = Join-Path $PWD.Path "edge_data"
docker run -d --privileged --network host --pull always --restart always -v "${edgeDataPath}:/xyte/edge_data" --name xyte_edge xytetech/xyte_edge:staging-stable-latest | Out-Null

# proxy name file (created by container)
$file = Join-Path $edgeDataPath "proxy_name.txt"

Write-Host "`nWaiting for the Edge ID to be generated. This might take up to 60 seconds..."

# Wait for the file to exist, but no longer than 60 seconds
$timeout = 60
$elapsed = 0
while (-not (Test-Path $file) -and ($elapsed -lt $timeout)) {
    Start-Sleep -Seconds 1
    $elapsed++
}

# If file still does not exist after timeout, exit with prompt
if (-not (Test-Path $file)) {
    Write-Host "Unable to print Edge ID, please verify Edge is running using 'docker ps' and if so find Edge id using 'Get-Content .\edge_data\proxy_name.txt'."
    exit 1
}

# Once the file exists, Read the content of the file into a variable
$file_content = Get-Content $file

# Print proxy name
Write-Host "`nEdge ID: $file_content"
Write-Host "To claim this Edge, please visit
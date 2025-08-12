# Xyte Connect+ Edge

## Windows PowerShell Installation

1. Download the PowerShell runner script:

```
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/xyte-io/edge/refs/heads/windows-main/edge_runner_script.ps1" -OutFile "edge_runner_script.ps1"
```

2. Run the script in PowerShell:

```
powershell -ExecutionPolicy Bypass .\edge_runner_script.ps1
```
or
```
.\edge_runner_script.ps1
```
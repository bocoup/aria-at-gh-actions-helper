$URL = "$env:JAWS_VERSION"

# check if we have admin rights
if (-Not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Write-Host "This script requires administrative privileges. Please run it as an administrator."
    exit 1
}
Write-Host "[x] Running with administrative privileges."

# download JAWS
$InstallerDestination = $URL.Split("/")[-1]
if (-Not (Test-Path $InstallerDestination))
{
    Write-Host "Downloading JAWS from $URL..."
    $ProgressPreference = 'SilentlyContinue' # make it faster
    Invoke-WebRequest -Uri $URL -OutFile $InstallerDestination
    if (-Not (Test-Path $InstallerDestination))
    {
        Write-Host "[ ] Download failed. Please check the URL or your internet connection."
        exit 1
    }
}
else
{
    Write-Host "[x] JAWS installer already exists at $InstallerDestination. Skipping download."
}

# install JAWS
$TargetPath = "C:\Program Files\Freedom Scientific\JAWS\2025\"
$TargetJAWSFile = $TargetPath + "jfw.exe"
if (-Not (Test-Path $TargetJAWSFile))
{
    Write-Host "Installing JAWS from $InstallerDestination..."
    Start-Process -FilePath $InstallerDestination -Wait
    if (-Not (Test-Path $TargetJAWSFile))
    {
        Write-Host "[ ] JAWS installation failed."
        exit 1
    }
}
else
{
    Write-Host "[x] JAWS installed successfully at $TargetPath"
}
$TargetRemoteCommandServer = $TargetPath + "RemoteCommandServer.dll"
if (-Not (Test-Path $TargetRemoteCommandServer))
{
    Write-Host "[ ] Remote Command Server installation failed. Please check additionalsettings.ini and try again."
    exit 1
}
else
{
    Write-Host "[x] Remote Command Server installed successfully"
}

#install license
$LicenseFileSourceFile = "secret_JAWS.lic"
$LicenseFileTargetFile = "JAWS.lic"
$LicenseFileTargetPath = "c:\ProgramData\Freedom Scientific\Auth\"
$LicenseFileTarget = $LicenseFileTargetPath + $LicenseFileTargetFile
if (-Not (Test-Path $LicenseFileTarget))
{
    # Copy source file to target while automatically renaming
    if (Test-Path $LicenseFileSourceFile) {
        Copy-Item -Path $LicenseFileSourceFile -Destination $LicenseFileTarget -Force
        Write-Host "[x] License file copied to $LicenseFileTarget."
    } else {
        Write-Host "[ ] License source file $LicenseFileSourceFile not found."
        exit 1
    }



    if (-Not (Test-Path $LicenseFileTarget))
    {
        Write-Host "[ ] License installation failed. Please check the license file and try again."
        exit 1
    }
    else
    {
        Write-Host "[x] License installed successfully at $LicenseFileTarget."
    }
}
else
{
    Write-Host "[x] License already exists at $LicenseFileTarget."
}

# configure firewall to allow jfw.exe have a server on port 9002
$firewallRuleName = "JAWS Remote Command Server inbound"
$port = 9002
$firewallRule = Get-NetFirewallRule -DisplayName $firewallRuleName -ErrorAction SilentlyContinue
if (-Not $firewallRule) {
    Write-Host "Creating firewall rule for JAWS Remote Command Server..."
    New-NetFirewallRule -DisplayName $firewallRuleName -Direction Inbound -Action Allow -Program $TargetJAWSFile -Protocol TCP -LocalPort $port
    if ($?)
    {
        Write-Host "[x] Inbound firewall rule created successfully."
    }
    else
    {
        Write-Host "[ ] Failed to create inbound firewall rule."
        exit 1
    }
}
else
{
    Write-Host "[x] Inbound firewall rule already exists."
}

$firewallRuleName = "JAWS Remote Command Server outbound"
$firewallRule = Get-NetFirewallRule -DisplayName $firewallRuleName -ErrorAction SilentlyContinue
if (-Not $firewallRule) {
    Write-Host "Creating outbound firewall rule for JAWS Remote Command Server..."
    New-NetFirewallRule -DisplayName $firewallRuleName -Direction Outbound -Action Allow -Program $TargetJAWSFile -Protocol TCP -LocalPort $port
    if ($?)
    {
        Write-Host "[x] Outbound firewall rule created successfully."
    }
    else
    {
        Write-Host "[ ] Failed to create outbound firewall rule."
        exit 1
    }
}
else
{
    Write-Host "[x] Outbound firewall rule already exists."
}

#start JAWS
# /startrcs starts JAWS with Remote Command Server enabled
# /default suppresses JAWS startup wizard
$JAWSProcess = Start-Process -FilePath $TargetJAWSFile -ArgumentList "/startrcs" -PassThru
if ($null -eq $JAWSProcess)
{
    Write-Host " [ ] Failed to start JAWS. Please check the installation and try again."
    exit 1
}
else
{
    Write-Host "[x] JAWS started successfully."
}

# check if JAWS Remote Command Server is responding
Write-Host "Checking if JAWS WS server is responding on port $port..." -NoNewline
$startTime = Get-Date
$endTime = (Get-Date).AddSeconds(90)
while ((Get-Date) -lt $endTime)
{
    $tcpConnection = Test-NetConnection -ComputerName "localhost" -Port $port -WarningAction SilentlyContinue
    if ($tcpConnection.TcpTestSucceeded)
    {
        $elapsed = (Get-Date) - $startTime
        Write-Host ""
        Write-Host "[x] JAWS WS server is responding on port $port after $elapsed seconds."
        break
    }
    Start-Sleep -Seconds 3
    Write-Host "." -NoNewline
}
Write-Host ""
if (-Not $tcpConnection.TcpTestSucceeded)
{
    $elapsed = (Get-Date) - $startTime
    Write-Host "[ ] JAWS WS server is not responding on port $port after $elapsed seconds."
    Write-Host "Restart JAWS with param /STARTRCS"
    exit
}

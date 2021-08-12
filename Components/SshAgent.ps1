# Set the ssh agent service to be started automatically
Get-Service -Name ssh-agent | Set-Service -StartupType Automatic

# Now start the service
Start-Service ssh-agent

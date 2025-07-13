#!/bin/bash

## SOURCE
# https://learn.microsoft.com/en-us/sql/linux/quickstart-install-connect-ubuntu?view=sql-server-ver16&tabs=ubuntu2204

#1.Download the public key, convert from ASCII to GPG format, and write it to the required location:
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg
curl https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc
curl -fsSL https://packages.microsoft.com/config/ubuntu/22.04/mssql-server-2022.list | sudo tee /etc/apt/sources.list.d/mssql-server-2022.list


sudo apt-get update
sudo apt-get install -y mssql-server


sudo /opt/mssql/bin/mssql-conf setup

# we use Standard(PAID so 5 or developer(free) so 1









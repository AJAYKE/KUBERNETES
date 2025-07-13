# DB MIGRATIOn SOURCE
# https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-migrate-restore-database?view=sql-server-ver16


sudo mkdir -p /mnt/dbdata/mssql
sudo mkdir -p /mnt/dbdata/mssql/data
sudo mkdir -p /mnt/dbdata/mssql/log
sudo chown -R mssql:mssql /mnt/dbdata

sudo mkdir -p /mnt/dbbackup
sudo chown -R mssql:mssql /mnt/dbbackup

# sudo mv /var/opt/mssql/backups /var/opt/mssql/backups.bak
sudo ln -s /mnt/dbbackup /var/opt/mssql/backups


sudo /opt/mssql/bin/mssql-conf set filelocation.defaultdatadir /mnt/dbdata/mssql/data/
sudo /opt/mssql/bin/mssql-conf set filelocation.defaultlogdir /mnt/dbdata/mssql/log/
sudo systemctl restart mssql-server
sudo /opt/mssql/bin/mssql-conf get filelocation


# 1. Create shared group
sudo groupadd dbaccess

# 2. Add both users to the group
sudo usermod -aG dbaccess ubuntu
sudo usermod -aG dbaccess mssql

# 3. Change group ownership recursively
sudo chown -R mssql:dbaccess /mnt/dbdata
sudo chown -R mssql:dbaccess /mnt/dbbackup
sudo chown -R mssql:dbaccess /var/opt/mssql

# 4. Set directory permissions (rwx for owner and group, none for others)
sudo find /mnt/dbdata /mnt/dbbackup /var/opt/mssql -type d -exec chmod 770 {} \;

# 5. Set file permissions (rw for owner and group)
sudo find /mnt/dbdata /mnt/dbbackup /var/opt/mssql -type f -exec chmod 660 {} \;

# 6. Set setgid on directories so new files inherit group
sudo find /mnt/dbdata /mnt/dbbackup /var/opt/mssql -type d -exec chmod g+s {} \;

newgrp dbaccess

# Check group memberships
groups ubuntu
groups mssql

# Confirm permissions
ls -ld /mnt/dbdata /mnt/dbbackup /var/opt/mssql
ls -la /mnt/dbdata
ls -la /mnt/dbbackup
ls -la /var/opt/mssql

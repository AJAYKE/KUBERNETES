### PREREQ CHECK

RUN this command on the master where it has access to all the nodes
```bash
curl -sSfL https://raw.githubusercontent.com/longhorn/longhorn/v1.8.1/scripts/environment_check.sh | bash
```

Ideal Output:

```bash
[INFO]  Required dependencies 'kubectl jq mktemp sort printf' are installed.
[INFO]  All nodes have unique hostnames.
[INFO]  Waiting for longhorn-environment-check pods to become ready (0/3)...
[INFO]  All longhorn-environment-check pods are ready (3/3).
[INFO]  MountPropagation is enabled
[INFO]  Checking kernel release...
[INFO]  Checking iscsid...
[INFO]  Checking multipathd...
[INFO]  Checking packages...
[INFO]  Checking nfs client...
[INFO]  Cleaning up longhorn-environment-check pods...
[INFO]  Cleanup completed.
```
But I got something like this:
![ERROR in Longhorn prereq checks](<Screenshot from 2025-03-18 16-38-58.png>)

### ISSUE:1 kernel module iscsi tep is not enabled on srv09019
```bash
sudo apt install open-iscsi
sudo modprobe iscsi_tcp
sudo systemctl enable iscsid
sudo systemctl start iscsid
sudo lsmod | grep iscsi
```


### ISSUE:2 nfs-common is not found in srv09019
```bash
sudo apt install nfs-common
```


### ISSUE:3 multipathd is running on srv09021
```bash
sudo systemctl disable multipathd multipathd.socket
sudo systemctl stop multipathd multipathd.socket
```


```bash
curl -sSfL https://raw.githubusercontent.com/longhorn/longhorn/v1.8.1/scripts/environment_check.sh | bash
```


## DEPLOY WITH HELM

```bash
helm repo add longhorn https://charts.longhorn.io
helm repo update
helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --version 1.8.1
kubectl -n longhorn-system get pod
```
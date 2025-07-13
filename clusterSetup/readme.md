# SIMPLE KUBERNETES DEPLOYMENT ON AWS INSTANCES.

First create an aws account and then an I AM user, get access key and secret key. you can find tonnes of youtube tutorials on this. Then run

```bash
aws configure
```

Then give access key and secret access key. Now we can start.
Go to aws.sh file and update your region there and just run that script on your machine.
At line 74, I have used _brew install jq_ coz am on mac, update accordingly for your machine, for windows you need chocolaty and linux sudo apt. If you want to change any other values, you can edit the values at the start. If you are editing the CIDR block, edit the instances ip address too.
Thats it, Run the script.

This script will take upto a minute, in between i added sleep for 20 seconds, the instance should be create by this time and you should get your ssh commands, if not go to your aws account, ec2 section and you will find two new instances, get public ips of these two machines and ssh into them. you will have ur rsa key in the same folder downloaded.

Now ssh into both the systems decide one of them as master and other one as worker.
Now create two files on master instance and one file on worker instance.

```bash
nano common.sh
```

copy paste the common.sh file in that

```bash
chmod +x common.sh
```

```bash
./common.sh
```

On master node

```bash
nano master.sh
```

copy paste the master.sh file in that

```bash
chmod +x master.sh
```

And then on master run run master.sh file

```bash
./master.sh
```

At the end you will get a token in the form of

```bash
kubeadm join <master_ip>:6443 --token sometokein --discovery-token-ca-c
ert-hash sha256:81cac80fb363b14..someencoded thing
```

Now copy paste this command on your worker nodes. Thats it your cluster will be up and running

```bash
kubectl get nodes -o wide
```

```bash
kubectl get pods -A
```

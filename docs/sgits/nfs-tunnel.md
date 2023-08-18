### or easy:
```bash
autossh -M <monitor_SSH_port> -N -L <your_local_port>:localhost:2049 <remote_server_user>@<remote_server> -f
mount -t nfs -o port=<your_local_port> localhost:/home/proudlygeek /mnt/nfs-share
```

### 1. Install NFS on Server
Install the required packages (Ubuntu 12.04):
```bash
apt-get install nfs-kernel-server portmap
```
    
### 2. Share NFS Folder
Open the exports file:
```bash
vim /etc/exports
```
    
Add the following line:
```bash
/home/proudlygeek  localhost(insecure,rw,sync,no_subtree_check)
```

Restart NFS Service:
```bash
service nfs-kernel-server restart
```
or just export the FS:
```bash
exportfs -a
```
    
### 3. Install NFS Client
Install the client:
```bash
apt-get install nfs-common portmap
```
Make a mount folder:
```bash
mkdir /mnt/nfs-share
```
Setup an SSH tunnel (local-to-remote port):
```bash
ssh -fNv -L 3049:localhost:2049 user@hostname
```
Mount the folder:
```bash
mount -t nfs -o port=3049 localhost:/home/proudlygeek /mnt/nfs-share
```
    

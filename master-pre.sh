#this file will be used in Jenkins to run the installation on Kube Master
#Run this as sudo

#configure the linux
#sudo su
apt-get update
swapoff -a

#install docker on master
apt-get install -y docker.io

#install curl
apt-get update && apt-get install -y apt-transport-https curl

#Add the key for Kubernetes
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add

#Add the kubernetes resourcces in the repo list
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

#update the repo
apt-get update

#install kubernetes tools
apt-get install -y kubelet kubeadm kubectl

#environment configuration of Kubernetes
if [ ! $(cat /etc/systemd/system/kubelet.service.d/10-kubeadm.conf | grep "Environment="cgroup-driver=systemd/cgroup-driver=cgroupfs"" ) ];
then
echo "Environment="cgroup-driver=systemd/cgroup-driver=cgroupfs""  >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
else
echo "Environment driver configured"
fi;
#reboot vm
shutdown --reboot +1 "System is going down for reboot in 1 minute"

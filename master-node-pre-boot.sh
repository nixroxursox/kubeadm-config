#!/bin/bash

u_name=`who | tr -s " "|cut -d" " -f1`

if [[ `sudo -l -U $u_name` && `id -u` -eq 0 ]];
then

echo -e "\nUser <$u_name>  have sudo priviledge";
echo -e "User <$u_name> is executing with sudo "

echo -e "\n-------------------------------------\n"
echo -e "Updateting the server\n"
#configure the linux

apt-get update
swapoff -a

if [[ `echo $? -e 0` ]]
then
echo -e "\n-------------------------------------\n"
echo -e "Installing Docker \n"

apt-get install -y docker.io

if [[ `echo $? -e 0` ]]
then
echo -e "\n-------------------------------------\n"
echo -e "Installing curl and https \n"

apt-get update && apt-get install -y apt-transport-https curl

if [[ `echo $? -e 0` ]]
then
echo -e "\n-------------------------------------\n"

echo -e "\nAdding kubernetes resourcces in the repo list"

cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF


if [[ `echo $? -e 0` ]]
then
echo -e "\n-------------------------------------\n"
echo -e "Updateting the server\n"
apt-get update

if [[ `echo $? -e 0` ]]
then
echo -e "\n-------------------------------------\n"
echo -e "Installing the kubelet,kubeadm,kubectl\n"

apt-get install -y kubelet=1.14.0-00 kubeadm=1.14.0-00 kubectl=1.14.0-00


if [[ `echo $? -e 0` ]]
then
echo -e "\n-------------------------------------\n"
echo -e "Environment configuration of Kubernetes\n"

if [ ! $(cat /etc/systemd/system/kubelet.service.d/10-kubeadm.conf | grep "Environment="cgroup-driver=systemd/cgroup-driver=cgroupfs"" ) ];
then
echo "Environment="cgroup-driver=systemd/cgroup-driver=cgroupfs""  >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
else
echo "Environment driver configured"
fi;

if [[ `echo $? -e 0` ]]
then
echo -e "\n-------------------------------------\n"

echo -e "All steps completed sucessfully now rebooting the server\n"

shutdown --reboot +1 "System is going down for reboot in 1 minute"


else
echo -e "Environment configuration of Kubernetes\n"
exit 9
fi;


else
echo -e "Error in the kubelet,kubeadm,kubectl\n"
exit 9
fi;




else
echo -e "Error in the kubelet,kubeadm,kubectl\n"
exit 9
fi;




else
echo -e "Error in Adding kubernetes resourcces in the repo list\n"
exit 9
fi;





else
echo -e "Error in in installing curl and https\n"
exit 9
fi;


else
echo -e "Error in in installing Docker\n"
exit 9
fi;


else

echo -e "Error in in Updateting the server\n"
exit 9
fi;

else
echo -e "\nUser <$u_name> dont have sudo priviledge"
echo -e "Or"
echo -e "Not using sudo keyword"
exit 9
fi;

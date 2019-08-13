cd ./kubeadm-config/

token=`cat token_create.txt`

#to reset the kubeadm if any cluster running
sudo kubeadm reset -f

sudo `echo $token`

if [ `echo $?` -eq "0" ]
then
        echo "Node joined the master sucessfully"

else
        echo "Error in Join node"
        exit 9
fi;

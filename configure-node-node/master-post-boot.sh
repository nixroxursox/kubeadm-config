#initialize the kube-adm
#if already installed and running then reset the cluster
data=`kubectl cluster-info| grep running | grep -o master| wc -l`

#if the cluser is installed and running
if [ "$data" -eq 1 ];
    then

    sudo kubeadm reset -f
	reset_flag=`echo $?`			#to check if any error during the Kubeadm reset
    echo "Kubeadm reset sucessfully !"
	
    #if reset sucessfull then
    if [ "$reset_flag" -eq 0 ]
        then

        #initialize the kubeadm cluster on the private ip the linux server
        sudo kubeadm init --apiserver-advertise-address=`ip -h -br address | grep eth0 | tr -s " " |cut -d" " -f3 | cut -d"/" -f1`
        flag=`echo $?`

    #if error in reset then exit
    else

        echo "Error while reset of Kubeadm cluster"
        exit 9
    fi;

else

    #else when the cluser is not working the initiated the kubeadm directly
    sudo kubeadm init --apiserver-advertise-address=`ip -h -br address | grep eth0 | tr -s " " |cut -d" " -f3 | cut -d"/" -f1`
    flag=`echo $?`
fi;    

#check if error while initiating kubeadm  
if [ "$flag" -eq 0 ]
    then
    echo "Kubeamd Sucessfully initiated !"


	#to start the cluster on other user run below
	mkdir -p $HOME/.kube
	sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
	sudo chown $(id -u):$(id -g) $HOME/.kube/config
	
	#wait till all pods comes up and then check which are in pending status
	until [ $(kubectl get pods --field-selector status.phase=Running --all-namespaces  --no-headers=true | wc -l) -eq 5 ]
	do
		echo "Waiting for pods get created after initialization..."
		sleep 10s
		if [ $(kubectl get pods --field-selector status.phase=Running --all-namespaces  --no-headers=true | wc -l) -eq 5 ]
		then
			echo "All Pods Up with 2 in Pending"
			break;
		fi;
	done;

	#Test if all pods are in Pending for network configuration status
	pending_pods=`kubectl get pods --field-selector status.phase=Pending --all-namespaces  --no-headers=true | wc -l`
	
	if [ "$pending_pods" -gt 0 ]
	then
		#Configure the network
		kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
        if [ `echo $?` -eq 0 ]
        then
        echo "Kubeadm Network pod configured"
        fi;
	fi;
#check if all pods are working

	
	until [ $(kubectl get pods --field-selector status.phase=Pending --all-namespaces  --no-headers=true | wc -l) -eq 0 ]
	do
		echo "Waiting for pods to come up after Network configuration..."
		sleep 10s
		if [ $(kubectl get pods --field-selector status.phase=Pending --all-namespaces  --no-headers=true | wc -l) -eq 0 ]
		then
			echo "All Pods Up and running !"
			break;
		fi;
	done;

    echo "Kubeadm configuration completed on Master sucessfully !"

else
    echo "Kubeadm Failed Initiation"
    exit 9
fi;
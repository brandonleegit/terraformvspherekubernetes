# Terraform vSphere Kubernetes automated lab
## Terraform vSphere Kubernetes automated Lab Build v1.0 - See the official blog post here: https://www.virtualizationhowto.com/2021/12/terraform-vsphere-kubernetes-automated-lab-build-in-8-minutes/ 
## Author - Brandon Lee https://www.virtualizationhowto.com

This is an automated Terraform script that:

- Builds the (3) Ubuntu VMs using an Ubuntu 21.04 vSphere template (built with Packer as linked above)
- Sets DNS - this is kind of kludgy how I am setting the DNS server.  However, haven't found a reliable way to set this with Terraform as of yet.  I welcome comments on this.
- Installs all the available Ubuntu updates - runs in "non interactive mode."  In doing some Googling found this to be effect to suppress the "service restart" prompts you get when installing Ubuntu updates.
- Configures root for logging in via SSH - You can comment this out if needed as it doesn't really affect your Kubernetes install.  You can always sudo the underprivileged user of your choosing.  The Packer build I have linked to creates an ubuntu/ubuntu user.
- Also sets a password for root - Again can be commented out
- Installs prereqs for Docker, Docker keyring, and then installs Docker - Container runtime used for the automated build.
- Installs prereqs for Kubernetes, kubeadm, and kubectl - Normal stuff needed for 
- Turns off swap
- Puts Kubernetes, kubeadm, and kubectl on hold so these can be closely controlled
- Change the Docker cgroup to systemd
- Restarts Docker services

After running the script, the resulting VMs are created in your vSphere environment ready to configure Kubernetes.


On the Kubernetes master/controller:

If you use the naming I have used, this is .  Run the following:

##Configure Kubernetes

kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=all

##Configure kubectl to work with your cluster

- mkdir -p $HOME/.kube
- sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
- sudo chown $(id -u):$(id -g) $HOME/.kube/config

##Install your Kubernetes networking (choose one of the below):

- Flannel
  kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

- Calico
  kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml</code></pre>



On the two worker nodes

##Run the kubeadm join command displayed on the Master/controller node, it will look like the following:

kubeadm join 10.1.149.123:6443 --token pqrc0n.iow5e2zycn5bu1uc \
        --discovery-token-ca-cert-hash sha256:7b6fd631048cc354927070a82a11e64e6afa539822a86058e335e3b3449979c4

##If you accidentally close your session and need to see the join command run the following on your master:

kubeadm token create --print-join-command

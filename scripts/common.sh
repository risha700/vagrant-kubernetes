#! /bin/bash
export DEBIAN_FRONTEND=noninteractive
# disable swap 
sudo swapoff -a
# keeps the swaf off during reboot
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

sudo apt-get update -y
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg


echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io -y

# Following configurations are recomended in the kubenetes documentation for Docker runtime. Please refer https://kubernetes.io/docs/setup/production-environment/container-runtimes/#docker

cat <<EOF | sudo tee /etc/docker/daemon.json  > /dev/null 2>&1
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
sudo systemctl enable docker > /dev/null 2>&1
sudo systemctl daemon-reload > /dev/null 2>&1
sudo systemctl restart docker > /dev/null 2>&1

echo "Docker Runtime Configured Successfully"

# enable containerd-cri
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf > /dev/null 2>&1
overlay
br_netfilter
EOF
echo "containerd config add"


sudo modprobe overlay > /dev/null 2>&1
sudo modprobe br_netfilter > /dev/null 2>&1
echo "containerd config apply"

cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf > /dev/null 2>&1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
echo "CRI conf add"
# refresh system without boot
sudo sysctl --system > /dev/null 2>&1
echo "system reset"

sudo mkdir -p /etc/containerd > /dev/null 2>&1
sudo tee /etc/containerd/config.toml > /dev/null 2>&1 <<EOF
$(sudo containerd config default) 
EOF
echo "containered config copied to /etc/containerd/config.toml"

sudo sed -i'' 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

sudo systemctl restart containerd > /dev/null 2>&1
sudo systemctl enable containerd > /dev/null 2>&1
sudo sysctl --system > /dev/null 2>&1
sudo systemctl restart docker > /dev/null 2>&1



echo "Docker Runtime Configured Successfully"


sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
# sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --yes --no-tty --dearmor -o /usr/share/keyrings/kubernetes-archive-keyring.gpg 
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update -y

sudo apt-get install -y kubelet kubectl kubeadm

sudo apt-mark hold kubelet kubeadm kubectl


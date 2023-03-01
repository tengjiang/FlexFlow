#! /bin/bash

# Clone repo
cd $HOME
git clone --recursive https://github.com/tengjiang/FlexFlow.git

# Making file system on mnt4 and sda4 onto /mnt
mkfs.ext4 /dev/sda4
mount /dev/sda4 /mnt/

cd /mnt
wget https://developer.download.nvidia.com/compute/cuda/11.7.0/local_installers/cuda_11.7.0_515.43.04_linux.run

mkdir /mnt/tmp
sh cuda_11.7.0_515.43.04_linux.run --silent --driver --toolkit --toolkitpath=/mnt/cuda --tmpdir=/mnt/tmp

# Setup CUDA paths
echo 'export PATH=/mnt/cuda/bin${PATH:+:${PATH}}' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/mnt/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}' >> ~/.bashrc
source ~/.bashrc
ldconfig

# install Docker
apt-get -y remove docker docker-engine docker.io containerd runc
apt-get -y update
apt-get -y install ca-certificates curl gnupg lsb-release
mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get -y update
apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
# sudo docker run hello-world

# install Nvidia Docker
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
      && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
      && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
            sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
            tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
apt-get -y update
apt-get install -y nvidia-container-toolkit
mkdir /etc/docker # make sure this directory is present
nvidia-ctk runtime configure --runtime=docker
systemctl restart docker

# Store images and containers on mounted disk
docker rm -f $(sudo docker ps -aq); sudo docker rmi -f $(sudo docker images -q)
systemctl stop docker
rm -rf /var/lib/docker
mkdir /var/lib/docker
mkdir /mnt/docker
mount --rbind /mnt/docker /var/lib/docker
systemctl start docker
chmod 666 /var/run/docker.sock

# Pull flexflow CUDA
cd $HOME/FlexFlow
sudo  ./docker/pull.sh flexflow-cuda
sudo FF_GPU_BACKEND=cuda ./docker/build.sh flexflow
sudo FF_GPU_BACKEND=cuda ./docker/run.sh flexflow
exit

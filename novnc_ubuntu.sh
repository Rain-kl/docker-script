#!/bin/bash

# required packages: curl

main(){
  install_docker
  install_docker_compose
  if [ -e "docker-compose.yml" ]; then
    echo "docker-compose.yml file exists, please delete it first"
    exit 1
  else
    echo "ok"
  fi
  #########################
  install_novnc_ubuntu
  #########################
  echo "Installation successful"

}

install_novnc_ubuntu(){
  mkdir ubuntu-xfce-vnc

  if [ -e "docker-compose.yml" ]; then
    echo "docker-compose.yml file exists, please delete it first"
    exit 1
  else
    echo "ok"
  fi

  touch docker-compose.yml
  cat <<EOF > docker-compose.yml
version: '3.5'

services:
    ubuntu-xfce-vnc:
        container_name: xfce
        image: imlala/ubuntu-xfce-vnc-novnc:latest
        shm_size: "1gb"  # Prevent Chromium from crashing at high resolutions, and increase it a little if there is enough memory
        ports:
            - 5900:5900   # TigerVNC service port (ensure that the port is not occupied, the port to the right of the colon cannot be changed, and the port on the left can be changed)
            - 6080:6080   # noVNC service port, the precautions are the same as above
        environment:
            - VNC_PASSWD=password    # Change to the password you want
            - GEOMETRY=1400x800      # Screen resolution, 800×600/1024×768 and so on
            - DEPTH=24               # The number of color bits is 16/24/32 available, the higher the picture, the more delicate the picture, but the network is not good, it will also be more stuck
        volumes:
            - ~/ubuntu-xfce-vnc/Downloads:/root/Downloads
            - ~/ubuntu-xfce-vnc/Documents:/root/Documents
        restart: unless-stopped
EOF
  docker-compose up -d
  mv docker-compose.yml ubuntu-xfce-vnc
}



install_docker(){
#  check docker is installed
  if ! command -v docker &> /dev/null; then
    echo "docker could not be found"
  else
    echo "docker is installed"
    return
  fi
  # shellcheck disable=SC2162

  read -p "Do you want to download from Aliyun? (y/n) (default n): " choice

  case "$choice" in
    y|Y ) curl -fsSL https://github.com/tech-shrimp/docker_installer/releases/download/latest/linux.sh| bash -s docker --mirror Aliyun;;
    * ) curl -sSL https://get.docker.com/ | sh;;
  esac
}


install_docker_compose(){
  # Determine the Linux distribution and call the appropriate function
if [ -f /etc/os-release ]; then
  . /etc/os-release
  case "$ID" in
    ubuntu|debian)
      install_docker_compose_on_ubuntu
      ;;
    alpine)
      install_docker_compose_on_alpine
      ;;
    centos|rhel|fedora)
      install_docker_compose_on_centos
      ;;
    *)
      echo "Unsupported Linux distribution: $ID"
      exit 1
      ;;
  esac
else
  echo "Cannot determine the Linux distribution."
  exit 1
fi

}


# Function to install packages on Ubuntu/Debian
install_docker_compose_on_ubuntu() {
  # check docker-compose is installed

  if ! command -v docker-compose &> /dev/null; then
    echo "docker-compose could not be found"
    apt update
    apt install -y docker-compose
  else
    echo "docker-compose is installed"
  fi
}

# Function to install packages on Alpine
install_docker_compose_on_alpine() {
  # check docker-compose is installed
  if ! command -v docker-compose &> /dev/null; then
    echo "docker-compose could not be found"
    apk update
    apk add docker-compose
  else
    echo "docker-compose is installed"
  fi
}

# Function to install packages on CentOS/RHEL
install_docker_compose_on_centos() {
  # check docker-compose is installed
  if ! command -v docker-compose &> /dev/null; then
    echo "docker-compose could not be found"
    yum -y update
    yum install -y docker-compose
  else
    echo "docker-compose is installed"
  fi
}

main

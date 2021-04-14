#!/bin/bash

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#                                                                       +
# Server Setup Script - set up docker mern on a new server              +
#                                                                       +
# https://github.com/NanoCode012/docker-mern                            +
#                                                                       +
# Script developed by                                                   +
#   Chanvichet Vong <kevinvong@rocketmail.com>                          +
#                                                                       +
# Copyright 2021 Chanvichet Vong                                        +
# License at                                                            +
#   https://github.com/NanoCode012/docker-mern/blob/main/LICENSE        +
#                                                                       +
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

echo "Docker-Mern server startup script by Chanvichet Vong"
echo "Get latest at https://github.com/NanoCode012/docker-mern/"
echo ""

BRANCH="initial" # for dev only

SCRIPT_PATH="$(dirname "$(readlink -f "$0")")"
SCRIPT_NAME="${0##*/}"

# Function to read input from user with a prompt
# Credits: https://github.com/TheRemote/MinecraftBedrockServer/blob/1f27b8ab82f920bb967d1c27ee2fd120a484c99c/SetupMinecraft.sh
function read_with_prompt {
  variable_name="$1"
  prompt="$2"
  default="${3-}"
  unset $variable_name
  while [[ ! -n ${!variable_name} ]]; do
    read -p "$prompt: " $variable_name < /dev/tty
    if [ ! -n "`which xargs`" ]; then
      declare -g $variable_name=$(echo "${!variable_name}" | xargs)
    fi
    declare -g $variable_name=$(echo "${!variable_name}" | head -n1 | awk '{print $1;}')
    if [[ -z ${!variable_name} ]] && [[ -n "$default" ]] ; then
      declare -g $variable_name=$default
    fi
    echo -n "$prompt : ${!variable_name} -- accept (y/n)?"
    read answer < /dev/tty
    if [ "$answer" == "${answer#[Yy]}" ]; then
      unset $variable_name
    else
      echo "$prompt: ${!variable_name}"
    fi
  done
}

function read_yes_no {
  variable_name="$1"
  prompt="$2"
  unset $variable_name

  read -p "$prompt -- (y/n)?" answer
  case ${answer:0:1} in
      y|Y )
          declare -g $variable_name=true
      ;;
      * )
          declare -g $variable_name=false
      ;;
  esac
}

if [ ! -d "docker-mern" ]; then
    mkdir docker-mern
else
    echo "Moving old docker-mern folder to docker-mern-backup folder"

    if [ -d "docker-mern-backup" ]; then
        echo "Deleting backup folder"
        rm -rf docker-mern-backup
        echo "Deleted backup folder"
    fi
    mv docker-mern docker-mern-backup

    mkdir docker-mern
    echo "Successfully moved to docker-mern-backup folder"
    echo ""
fi

# cd into folder
cd docker-mern

# Download env file
echo "Downloading env file"
wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/.env" -qO .env
source .env
echo "Downloaded env file"

# Server configuration
# read_with_prompt USE_EXTERNAL_REVERSE_PROXY "Do you use an external reverse proxy like nginx-proxy-automation? (y/n) " "y"
read_with_prompt NGINX_NAME "Nginx container name" "mern-nginx"
read_with_prompt CLIENT_NAME "Client container name" "mern-client"
read_with_prompt BACKEND_NAME "Backend container name" "mern-backend"
read_with_prompt DB_NAME "Database container name" "mern-db"
read_with_prompt PROXY_NAME "Docker external proxy name" "proxy"

echo "NGINX_NAME=$NGINX_NAME"           >> .env
echo "CLIENT_NAME=$CLIENT_NAME"         >> .env
echo "BACKEND_NAME=$BACKEND_NAME"       >> .env
echo "DB_NAME=$DB_NAME"                 >> .env
echo "PROXY_NAME=$PROXY_NAME"           >> .env # assume that network exists for now
echo ""

# Get docker-compose files
# wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/docker-compose.yml"
# wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/docker-compose.prod.yml"
# wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/docker-compose.override.yml"

# Create client app
echo "Client"
echo "======"

mkdir client

read_yes_no check_create_new_react_app "Create new react app"

if [ "$check_create_new_react_app" = true ]; then
    echo "Creating new react app"
    sudo docker run --rm -v $(pwd)/client:/client node:$DOCKER_NODE_VERSION npx create-react-app client --use-npm
    sudo chown -R ${USER}:${USER} client
    echo "Created new react app"
fi

cd client

echo "Downloading Dockerfile, Dockerfile.dev, .gitignore, and .dockerignore"
wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/client/Dockerfile" -qO Dockerfile
wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/client/Dockerfile.dev" -qO Dockerfile.dev
wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/client/.gitignore" -qO .gitignore
wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/client/.dockerignore" -qO .dockerignore
echo "Downloaded files"
echo ""

cd ..

# Create backend app
echo "Backend"
echo "======="

mkdir backend

read_yes_no check_create_new_backend_app "Create new node app"

if [ "$check_create_new_backend_app" = true ]; then
    echo "Creating new node app"
    sudo docker run --rm -v $(pwd)/backend:/backend node:$DOCKER_NODE_VERSION npm init -y
    sudo chown -R ${USER}:${USER} backend
    echo "Created new node app"
fi

cd backend

# echo "Downloading Dockerfile, Dockerfile.dev, .gitignore, and .dockerignore"
# wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/backend/Dockerfile" -qO Dockerfile
# wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/backend/Dockerfile.dev" -qO Dockerfile.dev
# wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/backend/.gitignore" -qO .gitignore
# wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/backend/.dockerignore" -qO .dockerignore
# echo "Downloaded files"
echo ""





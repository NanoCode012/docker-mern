#!/bin/bash
# Run: ./setup-server.sh

echo "Docker-Mern server startup script by NanoCode012"
echo "Get latest at https://github.com/NanoCode012/docker-mern/"
echo "\n"

BRANCH="inital" # for dev only

SCRIPT_PATH="$(dirname "$(readlink -f "$0")")"
SCRIPT_NAME="${0##*/}"
echo $SCRIPT_PATH
echo $SCRIPT_NAME

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

if [ ! -d "docker-mern" ]; then
    mkdir docker-mern
else
    echo "Moving old docker-mern folder to docker-mern.backup folder"
    mv docker-mern docker-mern.backup
    mkdir docker-mern
    echo "Successfully moved to docker-mern.backup folder"
    echo "\n"
fi

cd docker-mern

# Get docker-compose files
# wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/docker-compose.yml"
# wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/docker-compose.prod.yml"
# wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/docker-compose.override.yml"

# Create env file
touch .env

# Server configuration
# read_with_prompt USE_EXTERNAL_REVERSE_PROXY "Do you use an external reverse proxy like nginx-proxy-automation? (y/n) " "y"
read_with_prompt NGINX_NAME "Nginx container name" "mern-nginx"
read_with_prompt CLIENT_NAME "Client container name" "mern-client"
read_with_prompt BACKEND_NAME "Backend container name" "mern-backend"
read_with_prompt DB_NAME "Database container name" "mern-db"
read_with_prompt PROXY_NAME "Docker proxy name" "proxy"

echo "NGINX_NAME=$NGINX_NAME"           >> .env
echo "CLIENT_NAME=$CLIENT_NAME"         >> .env
echo "BACKEND_NAME=$BACKEND_NAME"       >> .env
echo "DB_NAME=$DB_NAME"                 >> .env
echo "PROXY_NAME=$PROXY_NAME"           >> .env
echo "\n"

# Create client app



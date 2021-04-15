#!/bin/bash

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#                                                                       +
# Server Setup Script - set up Docker MERN on a new server              +
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

echo "========================================================="
echo "Docker-Mern server startup script by Chanvichet Vong"
echo "Get latest at https://github.com/NanoCode012/docker-mern/"
echo "========================================================="
echo ""

BRANCH="initial" # for dev only

SCRIPT_PATH="$(dirname "$(readlink -f "$0")")"
SCRIPT_NAME="${0##*/}"

echo "Downloading base scripts"
wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/local-scripts.sh" -qO local-scripts.sh
source local-scripts.sh
echo "Downloaded base scripts"
echo ""

if [[ ! -z "$1" && "$1" == "barebone" ]]; then
    echo -e "Setting barebone run \n"
    barebone_run=true
else 
    barebone_run=false
fi

echo "Folder setup"
echo "============"

if [ ! -d "docker-mern" ]; then
    mkdir docker-mern
else
    echo "Moving old docker-mern folder to docker-mern-backup folder"

    if [ -d "docker-mern-backup" ]; then
        echo "Deleting backup folder"
        sudo chown -R ${USER}:${USER} docker-mern-backup # fix permission with db belonging to root
        rm -rf docker-mern-backup
        echo "Deleted backup folder"
    fi
    mv docker-mern docker-mern-backup

    mkdir docker-mern
    echo "Successfully moved to docker-mern-backup folder"
fi
echo ""

# Server configuration
echo "Configuration"
echo "============="

cd docker-mern

# Download LICENSE
echo "Downloading LICENSE"
wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/LICENSE" -qO LICENSE
echo "Downloaded LICENSE"

# Download env file
echo "Downloading env file"
wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/.env.sample" -qO .env
source .env
echo "Downloaded env file"

# Download ignore files
echo "Downloading .*ignore files"
wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/.gitignore" -qO .gitignore
wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/.dockerignore" -qO .dockerignore
echo "Downloaded .*ignore files"

# Get docker-compose files
wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/docker-compose.yml" -qO docker-compose.yml
wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/docker-compose.prod.yml" -qO docker-compose.prod.yml
wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/docker-compose.ssl.yml" -qO docker-compose.ssl.yml
wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/docker-compose.override.yml" -qO docker-compose.override.yml

if [ "$barebone_run" = true ]; then
    NGINX_NAME="mern-nginx"
    CLIENT_NAME="mern-client"
    BACKEND_NAME="mern-backend"
    DB_NAME="mern-db"
    PROXY_NAME="proxy"
else 
    # read_with_prompt USE_EXTERNAL_REVERSE_PROXY "Do you use an external reverse proxy like nginx-proxy-automation? (y/n) " "y"
    # todo: container names regex [a-zA-Z0-9][a-zA-Z0-9_.-]
    read_with_prompt NGINX_NAME "Nginx container name" "mern-nginx"
    read_with_prompt CLIENT_NAME "Client container name" "mern-client"
    read_with_prompt BACKEND_NAME "Backend container name" "mern-backend"
    read_with_prompt DB_NAME "Database container name" "mern-db"
    read_with_prompt PROXY_NAME "Docker external proxy name" "proxy"
fi

echo "NGINX_NAME=$NGINX_NAME"           >> .env
echo "CLIENT_NAME=$CLIENT_NAME"         >> .env
echo "BACKEND_NAME=$BACKEND_NAME"       >> .env
echo "DB_NAME=$DB_NAME"                 >> .env
echo "PROXY_NAME=$PROXY_NAME"           >> .env # assume that network exists for now
echo ""

# Create client app
echo "Client"
echo "======"

mkdir client

if [ "$barebone_run" = false ]; then
    read_yes_no check_create_new_react_app "Create new react app"

    if [ "$check_create_new_react_app" = true ]; then
        echo "Creating new react app"
        sudo docker run --rm -v $(pwd)/client:/client node:$DOCKER_NODE_VERSION npx create-react-app client --use-npm
        sudo chown -R ${USER}:${USER} client
        echo "Created new react app"
    fi
fi

cd client

mkdir nginx

echo "Downloading Dockerfile, Dockerfile.dev, .gitignore, .dockerignore, and nginx conf file"
wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/client/Dockerfile" -qO Dockerfile
wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/client/Dockerfile.dev" -qO Dockerfile.dev
wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/client/.gitignore" -qO .gitignore
wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/client/.dockerignore" -qO .dockerignore
wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/client/nginx/default.conf" -qO nginx/default.conf
echo "Downloaded files"
echo ""

cd ..

# Create backend app
echo "Backend"
echo "======="

mkdir backend

if [ "$barebone_run" = false ]; then
    read_yes_no check_create_new_backend_app "Create new node app"

    if [ "$check_create_new_backend_app" = true ]; then
        echo "Creating new node app"

        echo "Downloading startup script"
        wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/backend/startup.sh" -qO backend-startup.sh
        echo "Downloaded startup script"

        sudo docker run --rm -v $(pwd)/backend:/backend -v $(pwd)/backend-startup.sh:/backend-startup.sh \
            node:$DOCKER_NODE_VERSION /bin/sh -c "chmod +x backend-startup.sh && ./backend-startup.sh"
        
        echo "Deleting startup script"
        rm backend-startup.sh
        echo "Deleted startup script"

        echo "Downloading starter express code"
        mkdir backend/src
        wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/backend/src/index.js" -qO backend/src/index.js
        echo "Downloaded starter express code"

        sudo chown -R ${USER}:${USER} backend
        echo "Created new node app"
    fi
fi

cd backend

echo "Downloading Dockerfile, Dockerfile.dev, .gitignore, and .dockerignore"
wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/backend/Dockerfile" -qO Dockerfile
wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/backend/Dockerfile.dev" -qO Dockerfile.dev
wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/backend/.gitignore" -qO .gitignore
wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/backend/.dockerignore" -qO .dockerignore
echo "Downloaded files"
echo ""

cd ..

# Create db
echo "Database"
echo "========"

mkdir db
cd db

echo "Creating init-mongo.js file"
touch init-mongo.js
echo "Created init-mongo.js file. Please place your initial mongo configurations here."
echo ""

cd ..

# Create proxy
echo "Nginx Proxy"
echo "==========="

mkdir nginx
mkdir nginx/configs
cd nginx

echo "Downloading Dockerfile and nginx default conf"
wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/nginx/Dockerfile" -qO Dockerfile
wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/nginx/configs/default.conf" -qO configs/default.conf
echo "Downloaded files"

echo "Replacing conf variables with env variables"
CLIENT_NAME=$CLIENT_NAME BACKEND_NAME=$BACKEND_NAME envsubst < configs/default.conf > configs/default.conf.replaced
mv configs/default.conf.replaced configs/default.conf
echo "Replaced variables"
echo ""

cd ..

# Create environment folder
echo "Env"
echo "==="

mkdir env
cd env

echo "Downloading env files"
wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/env/backend.env.sample" -qO backend.env
wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/env/mongo.env.sample" -qO mongo.env
wget "https://raw.githubusercontent.com/NanoCode012/docker-mern/$BRANCH/env/nginx.env.sample" -qO nginx.env
echo "Downloaded env files"

if [ "$barebone_run" = true ]; then
    MONGO_INITDB_DATABASE="app"
    MONGO_INITDB_USERNAME="nanocode012"
    MONGO_INITDB_PASSWORD="averysecurepassword,butpleasechangeme0"
else 
    read_with_prompt MONGO_INITDB_DATABASE "MongoDB Database Name" "app"
    read_with_prompt MONGO_INITDB_USERNAME "MongoDB Username" "nanocode012"
    read_with_prompt MONGO_INITDB_PASSWORD "MongoDB Password" "averysecurepassword,butpleasechangeme0"
fi

echo "Replacing env file with env variables"
MONGO_INITDB_DATABASE=$MONGO_INITDB_DATABASE envsubst < backend.env > backend.env.replaced
mv backend.env.replaced backend.env

MONGO_INITDB_DATABASE=$MONGO_INITDB_DATABASE MONGO_INITDB_USERNAME=$MONGO_INITDB_USERNAME \
                    MONGO_INITDB_PASSWORD=$MONGO_INITDB_PASSWORD envsubst < mongo.env > mongo.env.replaced
mv mongo.env.replaced mongo.env
echo "Replaced variables"

if [ "$barebone_run" = false ]; then
    read_yes_no check_enable_ssl_app "Enable SSL via Nginx Proxy-LetsEncrypt"

    if [ "$check_enable_ssl_app" = true ]; then
        read_with_prompt VIRTUAL_HOST "VIRTUAL_HOST/LETSENCRYPT_HOST" ""
        read_with_prompt VIRTUAL_PORT "VIRTUAL_PORT" "80"
        read_with_prompt LETSENCRYPT_EMAIL "LETSENCRYPT_EMAIL" ""

        echo "Replacing env file with env variables"
        VIRTUAL_HOST=$VIRTUAL_HOST VIRTUAL_PORT=$VIRTUAL_PORT LETSENCRYPT_HOST=$VIRTUAL_HOST \
                                LETSENCRYPT_EMAIL=$LETSENCRYPT_EMAIL envsubst < nginx.env > nginx.env.replaced
        mv nginx.env.replaced nginx.env
        echo "Replaced variables"
    fi
fi

echo ""

cd ..

# Cleanup
echo "Clean up"
echo "==="

echo "Deleting local-scripts"
rm ../local-scripts.sh
echo "Deleted local scripts"
ARG DOCKER_NODE_VERSION

FROM node:$DOCKER_NODE_VERSION AS alpine

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm install 
COPY . .

EXPOSE 3001

# Default command
CMD ["npm", "run", "start"]

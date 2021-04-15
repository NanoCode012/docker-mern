#!/bin/sh

cd backend

npm init -y
npm install --save express

npm install --save-dev --silent nodemon 

npm set-script start "node src/index.js"
npm set-script test "nodemon src/index.js"
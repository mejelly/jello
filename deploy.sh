#!/bin/bash

cp .travis/proxy ~/.ssh/config
mv .travis/deploy_key ~/.ssh/id_rsa
chmod 400 ~/.ssh/id_rsa
sed -i "s#image: {}#image: $REPO:$COMMIT#g" docker-compose.production.yml
scp docker-compose.production.yml $STAGING_USERNAME:/home/mejelly/jello
pip install fabric
fab staging deploy

#!/bin/bash
figlet "DeployContract"
echo "contract's name: \t $2"

docker exec "$3" /bin/sh -c "./scripts/deploy_contract.sh $2 hackdapptube hackdappwalt \$(cat hackdappwalt_wallet_password.txt)"
#!/usr/bin/env bash
set -o errexit

echo "=== setup blockchain accounts and smart contract ==="

# set PATH
PATH="$PATH:/opt/eosio/bin:/opt/eosio/bin/scripts"

set -m

echo "=== install EOSIO.CDT (Contract Development Toolkit) ==="
apt install /opt/eosio/bin/scripts/eosio.cdt-1.3.2.x86_64.deb

# start nodeos ( local node of blockchain )
# run it in a background job such that docker run could continue
nodeos -e -p eosio -d /mnt/dev/data \
  --config-dir /mnt/dev/config \
  --http-validate-host=false \
  --plugin eosio::producer_plugin \
  --plugin eosio::chain_api_plugin \
  --plugin eosio::http_plugin \
  --plugin eosio::history_api_plugin \
  --http-server-address=0.0.0.0:8888 \
  --access-control-allow-origin=* \
  --contracts-console \
  --filter-on hackdappexch:log: \
  --max-transaction-time=1000 \
  --verbose-http-errors &

keosd --http-server-address=0.0.0.0:5555 &

sleep 1s
until curl localhost:8888/v1/chain/get_info
do
  sleep 1s
done

# Sleep for 2 to allow time 4 blocks to be created so we have blocks to reference when sending transactions
sleep 2s
echo "=== setup wallet: 1. eosio ==="
# eosio system account
cleos wallet create -n eosio --to-console | tail -1 | sed -e 's/^"//' -e 's/"$//' > eosio_wallet_password.txt
cleos wallet import -n eosio --private-key 5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3

echo "=== setup wallet: 2. testioadmin ==="
# account: eosio.token 
cleos wallet create -n eosio.token --to-console | tail -1 | sed -e 's/^"//' -e 's/"$//' > eosiotoken_wallet_password.txt
cleos wallet import -n eosio.token --private-key 5K7mtrinTFrVTduSxizUc5hjXJEtTjVTsqSHeBHes1Viep86FP5
cleos create account eosio eosio.token EOS6kYgMTCh1iqpq9XGNQbEi8Q6k5GujefN9DSs55dcjVyFAq7B6b EOS6kYgMTCh1iqpq9XGNQbEi8Q6k5GujefN9DSs55dcjVyFAq7B6b
# account: testio.token
cleos wallet create -n testio.token --to-console | tail -1 | sed -e 's/^"//' -e 's/"$//' > testio.token_wallet_password.txt
cleos wallet import -n testio.token --private-key 5KLqT1UFxVnKRWkjvhFur4sECrPhciuUqsYRihc1p9rxhXQMZBg
cleos create account eosio testio.token EOS78RuuHNgtmDv9jwAzhxZ9LmC6F295snyQ9eUDQ5YtVHJ1udE6p EOS78RuuHNgtmDv9jwAzhxZ9LmC6F295snyQ9eUDQ5YtVHJ1udE6p
# account: superadmin
cleos wallet create -n testioadmin --to-console | tail -1 | sed -e 's/^"//' -e 's/"$//' > testioadmin_wallet_password.txt
cleos wallet import -n testioadmin --private-key 5JpWT4ehouB2FF9aCfdfnZ5AwbQbTtHBAwebRXt94FmjyhXwL4K
cleos wallet import -n testioadmin --private-key 5JD9AGTuTeD5BXZwGQ5AtwBqHK21aHmYnTetHgk1B3pjj7krT8N

# account: feeadmin
cleos wallet create -n feeadmin --to-console | tail -1 | sed -e 's/^"//' -e 's/"$//' > feeadmin_wallet_password.txt
cleos wallet import -n feeadmin --private-key 5KDPndWLYtbpfWq2QVJZPwDauHwx7ZuGvEdmekvSBhErje4xKwP
cleos create account eosio feeadmin EOS83fgCT1h1JMvav4T93bZ7KY1JrbLaEUAZjYzB9aFuZAbTUtXfL EOS83fgCT1h1JMvav4T93bZ7KY1JrbLaEUAZjYzB9aFuZAbTUtXfL

# account: opsadmin
cleos wallet create -n opsadmin --to-console | tail -1 | sed -e 's/^"//' -e 's/"$//' > opsadmin_wallet_password.txt
cleos wallet import -n opsadmin --private-key  5KDig3Zs7igNPAR7fYRKjB6KmhFd61vTkr1ycx2X84e4ajT2PnT
cleos create account eosio opsadmin  EOS6TdDocsQcPDmhJw1MHdZVpCLvxdfjoLsBzAff7BB7zUS3ynjgQ EOS6TdDocsQcPDmhJw1MHdZVpCLvxdfjoLsBzAff7BB7zUS3ynjgQ  

# account: tradeadmin
cleos wallet create -n tradeadmin --to-console | tail -1 | sed -e 's/^"//' -e 's/"$//' > tradeadmin_wallet_password.txt
cleos wallet import -n tradeadmin --private-key 5JRi1jSwqKS2UCGUoXKaJyquHjC4kdL43SaU9nFWemtFERgKUwB
cleos create account eosio tradeadmin EOS7H8xqsUyAwCPDYfQ5RQYSFKzxeX5cuucMLAC6g31GuQEG9hdKz EOS7H8xqsUyAwCPDYfQ5RQYSFKzxeX5cuucMLAC6g31GuQEG9hdKz


echo "=== deploy smart contract ==="
# $1 smart contract name
# $2 account holder name of the smart contract
# $3 wallet for unlock the account
# $4 password for unlocking the wallet

deploy_contract.sh eosio.token eosio.token eosio $(cat eosio_wallet_password.txt)
deploy_contract.sh eosio.token testio.token testio.token $(cat testio.token_wallet_password.txt)

echo "=== init contract's data ==="
cleos push action eosio.token create '{"issuer":"eosio.token", "maximum_supply":"1000000000.0000 EOS"}' -p eosio.token
cleos push action testio.token create '{"issuer":"testio.token", "maximum_supply":"1000000000.0000 TESTIO"}' -p testio.token
cleos push action eosio.token issue '[ "eosio.token", "1000000000.0000 EOS", "memo" ]' -p eosio.token
cleos push action testio.token issue '[ "testio.token", "1000000000.0000 TESTIO", "memo" ]' -p testio.token

echo "=== create test accounts ==="
# script for create data into blockchain
create_accounts.sh

# * Replace the script with different form of data that you would pushed into the blockchain when you start your own project

echo "=== end of setup blockchain accounts and smart contract ==="
# create a file to indicate the blockchain has been initialized
touch "/mnt/dev/data/initialized"

# put the background nodeos job to foreground for docker run
fg %1

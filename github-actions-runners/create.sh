#!/bin/bash

NUM=${NUM:=1}

TOKEN=${TOKEN:="AB3KDAFJIALI3CE553D47CS6ZQFLW"}
URL=${URL:="https://github.com/Improbable-AI/monkey-job-runner"}


if [ -d "github-actions-runner-$NUM" ]; then
  cd "github-actions-runner-$NUM"
  sudo ./svc.sh uninstall
  ./config.sh remove \
 --url  "$URL" \
 --token "$TOKEN" \
 --name "seacow-$NUM" \
 --labels "seacow,ubuntu-local" \
 --work "_work" \
 --replace
 cd ../
 rm -rf "github-actions-runner-$NUM"
fi 

if [[ -v REMOVE ]]; then
	echo "Removed $NUM and exiting"
	exit
fi

mkdir "github-actions-runner-$NUM"
cd "github-actions-runner-$NUM"

curl -O -L https://github.com/actions/runner/releases/download/v2.262.1/actions-runner-linux-x64-2.262.1.tar.gz
tar xzf ./actions-runner-linux-x64-2.262.1.tar.gz

./config.sh \
 --url "$URL" \
 --token "$TOKEN" \
 --name "seacow-$NUM" \
 --labels "seacow,ubuntu-local" \
 --work "_work" \
 --replace

sudo ./svc.sh install
sudo ./svc.sh start 

cd ..

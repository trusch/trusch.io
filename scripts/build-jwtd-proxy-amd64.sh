#!/bin/bash

export GOPATH=$(pwd)/build

GOOS=linux GOARCH=amd64 go get -d -v github.com/trusch/jwtd/...
GOOS=linux GOARCH=amd64 go build -ldflags '-linkmode external -extldflags -static' -o build/jwtd-proxy.amd64 github.com/trusch/jwtd/jwtd-proxy

acbuild --debug begin

# In the event of the script exiting, end the build
trap "{ export EXT=$?; acbuild --debug end && exit $EXT; }" EXIT

acbuild --debug set-name trusch.io/jwtd-proxy
acbuild --debug dependency add trusch.io/alpine
acbuild --debug copy build/jwtd-proxy.amd64 /bin/jwtd-proxy
acbuild --debug set-exec -- /bin/jwtd-proxy
acbuild --debug write --overwrite aci/jwtd-proxy-amd64.aci

gpg --sign --armor --detach -u tino.rusch@gmail.com aci/jwtd-proxy-amd64.aci

exit $?

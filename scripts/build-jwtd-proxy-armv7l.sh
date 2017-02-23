#!/bin/bash

export GOPATH=$(pwd)/build

GOOS=linux GOARCH=arm go get -d -v github.com/trusch/jwtd/...
GOOS=linux GOARCH=arm go build -o build/jwtd-proxy.arm github.com/trusch/jwtd/jwtd-proxy

acbuild --debug begin

# In the event of the script exiting, end the build
trap "{ export EXT=$?; acbuild --debug end && exit $EXT; }" EXIT

acbuild --debug set-name kzw.io/jwtd-proxy
acbuild --debug label add arch armv7l
acbuild --debug dependency add trusch.io/alpine
acbuild --debug copy build/jwtd-proxy.arm /bin/jwtd-proxy
acbuild --debug set-exec -- /bin/jwtd-proxy
acbuild --debug write --overwrite aci/jwtd-proxy-armv7l.aci

gpg --sign --armor --detach -u tino.rusch@gmail.com aci/jwtd-proxy-armv7l.aci

exit $?

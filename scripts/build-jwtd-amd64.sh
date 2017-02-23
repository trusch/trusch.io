#!/bin/bash

export GOPATH=$(pwd)/build

GOOS=linux GOARCH=amd64 go get -d -v github.com/trusch/jwtd/...
GOOS=linux GOARCH=amd64 go build -ldflags '-linkmode external -extldflags -static' -o build/jwtd.amd64 github.com/trusch/jwtd
GOOS=linux GOARCH=amd64 go build -ldflags '-linkmode external -extldflags -static' -o build/jwtd-ctl.amd64 github.com/trusch/jwtd/jwtd-ctl

acbuild --debug begin

# In the event of the script exiting, end the build
trap "{ export EXT=$?; acbuild --debug end && exit $EXT; }" EXIT

acbuild --debug set-name trusch.io/jwtd
acbuild --debug dependency add trusch.io/alpine
acbuild --debug copy build/jwtd.amd64 /bin/jwtd
acbuild --debug copy build/jwtd-ctl.amd64 /bin/jwtd-ctl
acbuild --debug set-exec -- /bin/jwtd
acbuild --debug write --overwrite aci/jwtd-amd64.aci

gpg --sign --armor --detach -u tino.rusch@gmail.com aci/jwtd-amd64.aci

exit $?

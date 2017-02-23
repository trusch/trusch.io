#!/bin/bash

export GOPATH=$(pwd)/build

GOOS=linux GOARCH=amd64 go get -d -v github.com/trusch/http-echo
GOOS=linux GOARCH=amd64 go build -ldflags '-linkmode external -extldflags -static' -o build/http-echo.amd64 github.com/trusch/http-echo

acbuild --debug begin

# In the event of the script exiting, end the build
trap "{ export EXT=$?; acbuild --debug end && exit $EXT; }" EXIT

acbuild --debug set-name trusch.io/http-echo
acbuild --debug dependency add trusch.io/alpine
acbuild --debug copy build/http-echo.amd64 /bin/http-echo
acbuild --debug set-exec -- /bin/http-echo
acbuild --debug write --overwrite aci/http-echo-amd64.aci

gpg --sign --armor --detach -u tino.rusch@gmail.com aci/http-echo-amd64.aci

exit $?

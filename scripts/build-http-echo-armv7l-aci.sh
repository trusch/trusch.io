#!/bin/bash

export GOPATH=$(pwd)/build

GOOS=linux GOARCH=arm go get -d -v github.com/trusch/http-echo
GOOS=linux GOARCH=arm go build -o build/http-echo.arm github.com/trusch/http-echo

acbuild --debug begin

# In the event of the script exiting, end the build
trap "{ export EXT=$?; acbuild --debug end && exit $EXT; }" EXIT

acbuild --debug set-name trusch.io/http-echo
acbuild --debug label add arch armv7l
acbuild --debug dependency add trusch.io/alpine
acbuild --debug copy build/http-echo.arm /bin/http-echo
acbuild --debug set-exec -- /bin/http-echo
acbuild --debug write --overwrite aci/http-echo-armv7l.aci

gpg --sign --armor --detach -u tino.rusch@gmail.com aci/http-echo-armv7l.aci

exit $?

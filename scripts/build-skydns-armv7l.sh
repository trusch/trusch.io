#!/bin/bash

export GOPATH=$(pwd)/build
GOOS=linux GOARCH=arm go get -d -v github.com/skynetservices/skydns
GOOS=linux GOARCH=arm go build -ldflags '-linkmode external -extldflags -static' -o build/skydns.arm github.com/skynetservices/skydns

acbuild --debug begin

# In the event of the script exiting, end the build
trap "{ export EXT=$?; acbuild --debug end && exit $EXT; }" EXIT

acbuild --debug set-name kzw.io/skydns
acbuild --debug label add arch armv7l
acbuild --debug dependency add trusch.io/alpine
acbuild --debug copy build/skydns.arm /bin/skydns
acbuild --debug port add dns tcp 53
acbuild --debug write --overwrite aci/skydns-armv7l.aci

gpg --sign --armor --detach -u tino.rusch@gmail.com aci/skydns-armv7l.aci

exit $?

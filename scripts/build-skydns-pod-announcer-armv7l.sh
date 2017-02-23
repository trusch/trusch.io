#!/bin/bash

export GOPATH=$(pwd)/build
GOOS=linux GOARCH=arm go get -d -v github.com/trusch/skydns-pod-announcer
GOOS=linux GOARCH=arm go build -ldflags '-linkmode external -extldflags -static' -o build/skydns-pod-announcer.arm github.com/trusch/skydns-pod-announcer

acbuild --debug begin

# In the event of the script exiting, end the build
trap "{ export EXT=$?; acbuild --debug end && exit $EXT; }" EXIT

acbuild --debug set-name trusch.io/skydns-pod-announcer
acbuild --debug label add arch armv7l
acbuild --debug dependency add trusch.io/alpine
acbuild --debug copy build/skydns-pod-announcer.arm /bin/skydns-pod-announcer
acbuild --debug set-exec -- /bin/skydns-pod-announcer
acbuild --debug write --overwrite aci/skydns-pod-announcer-armv7l.aci

gpg --sign --armor --detach -u tino.rusch@gmail.com aci/skydns-pod-announcer-armv7l.aci

exit $?

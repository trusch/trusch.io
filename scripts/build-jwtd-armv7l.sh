#!/bin/bash

export GOPATH=$(pwd)/build

GOOS=linux GOARCH=arm go get -d -v github.com/trusch/jwtd/...
GOOS=linux GOARCH=arm go build -o build/jwtd.arm github.com/trusch/jwtd
GOOS=linux GOARCH=arm go build -o build/jwtd-ctl.arm github.com/trusch/jwtd/jwtd-ctl

acbuild --debug begin

# In the event of the script exiting, end the build
trap "{ export EXT=$?; acbuild --debug end && exit $EXT; }" EXIT

acbuild --debug set-name kzw.io/jwtd
acbuild --debug label add arch armv7l
acbuild --debug dependency add trusch.io/alpine
acbuild --debug copy build/jwtd.arm /bin/jwtd
acbuild --debug copy build/jwtd-ctl.arm /bin/jwtd-ctl
acbuild --debug set-exec -- /bin/jwtd
acbuild --debug write --overwrite aci/jwtd-armv7l.aci

gpg --sign --armor --detach -u tino.rusch@gmail.com aci/jwtd-armv7l.aci

exit $?

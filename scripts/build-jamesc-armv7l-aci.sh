#!/bin/bash

export GOPATH=$(pwd)/build

GOOS=linux GOARCH=arm go get -d -v github.com/trusch/jamesd/...
GOOS=linux GOARCH=arm go build -o build/jamesc.arm github.com/trusch/jamesd/cmd/jamesc

acbuild --debug begin

# In the event of the script exiting, end the build
trap "{ export EXT=$?; acbuild --debug end && exit $EXT; }" EXIT

acbuild --debug set-name trusch.io/jamesc
acbuild --debug label add arch armv7l
acbuild --debug dependency add trusch.io/alpine
acbuild --debug copy build/jamesc.arm /bin/jamesc
acbuild --debug set-exec -- /bin/jamesc
acbuild --debug write --overwrite aci/jamesc-armv7l.aci

gpg --sign --armor --detach -u tino.rusch@gmail.com aci/jamesc-armv7l.aci

exit $?

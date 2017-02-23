#!/bin/bash

export GOPATH=$(pwd)/build

GOOS=linux GOARCH=amd64 go get -d -v github.com/trusch/jamesd/...
GOOS=linux GOARCH=arm go build -o build/jamesd.arm github.com/trusch/jamesd/cmd/jamesd
GOOS=linux GOARCH=arm go build -o build/jamesd-ctl.arm github.com/trusch/jamesd/cmd/jamesd-ctl

acbuild --debug begin

# In the event of the script exiting, end the build
trap "{ export EXT=$?; acbuild --debug end && exit $EXT; }" EXIT

acbuild --debug set-name trusch.io/jamesd

acbuild --debug dependency add trusch.io/alpine
acbuild --debug label add arch armv7l
acbuild --debug copy build/jamesd.arm /bin/jamesd
acbuild --debug copy build/jamesd-ctl.arm /bin/jamesd-ctl
acbuild --debug set-exec -- /bin/jamesd
acbuild --debug write --overwrite aci/jamesd-armv7l.aci

gpg --sign --armor --detach -u tino.rusch@gmail.com aci/jamesd-armv7l.aci


exit $?

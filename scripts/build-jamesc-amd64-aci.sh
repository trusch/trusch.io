#!/bin/bash

export GOPATH=$(pwd)/build

GOOS=linux GOARCH=amd64 go get -d -v github.com/trusch/jamesd/...
GOOS=linux GOARCH=amd64 go build -ldflags '-linkmode external -extldflags -static' -o build/jamesc.amd64 github.com/trusch/jamesd/cmd/jamesc

acbuild --debug begin

# In the event of the script exiting, end the build
trap "{ export EXT=$?; acbuild --debug end && exit $EXT; }" EXIT

acbuild --debug set-name trusch.io/jamesc
acbuild --debug dependency add trusch.io/alpine
acbuild --debug copy build/jamesc.amd64 /bin/jamesc
acbuild --debug set-exec -- /bin/jamesc
acbuild --debug write --overwrite aci/jamesc-amd64.aci

gpg --sign --armor --detach -u tino.rusch@gmail.com aci/jamesc-amd64.aci

exit $?

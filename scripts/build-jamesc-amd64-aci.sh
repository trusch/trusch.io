#!/bin/bash

export GOPATH=$(pwd)/build

source scripts/versions.sh

GOOS=linux GOARCH=amd64 go get -d -v gopkg.in/trusch/jamesd.${JAMESD_VERSION}/...
GOOS=linux GOARCH=amd64 go build -ldflags '-linkmode external -extldflags -static' -o build/jamesc.amd64 gopkg.in/trusch/jamesd.${JAMESD_VERSION}/cmd/jamesc

VERSION=$(git -C $GOPATH/src/gopkg.in/trusch/jamesd.${JAMESD_VERSION} describe)

acbuild --debug begin

# In the event of the script exiting, end the build
trap "{ export EXT=$?; acbuild --debug end && exit $EXT; }" EXIT

acbuild --debug set-name trusch.io/jamesc
acbuild --debug label add version ${VERSION}
acbuild --debug dependency add trusch.io/alpine
acbuild --debug copy build/jamesc.amd64 /bin/jamesc
acbuild --debug set-exec -- /bin/jamesc
acbuild --debug write --overwrite aci/jamesc-${VERSION}-amd64.aci

yes | gpg --sign --armor --detach -u tino.rusch@gmail.com aci/jamesc-${VERSION}-amd64.aci

ln -s jamesc-${VERSION}-amd64.aci aci/jamesc-latest-amd64.aci
ln -s jamesc-${VERSION}-amd64.aci.asc aci/jamesc-latest-amd64.aci.asc

exit $?

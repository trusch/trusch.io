#!/bin/bash

export GOPATH=$(pwd)/build

source scripts/versions.sh

GOOS=linux GOARCH=arm go get -d -v gopkg.in/trusch/jamesd.${JAMESD_VERSION}/...
GOOS=linux GOARCH=arm go build -o build/jamesc.arm gopkg.in/trusch/jamesd.${JAMESD_VERSION}/cmd/jamesc

VERSION=$(git -C $GOPATH/src/gopkg.in/trusch/jamesd.${JAMESD_VERSION} describe)

acbuild --debug begin

# In the event of the script exiting, end the build
trap "{ export EXT=$?; acbuild --debug end && exit $EXT; }" EXIT

acbuild --debug set-name trusch.io/jamesc
acbuild --debug label add arch armv7l
acbuild --debug label add version ${VERSION}
acbuild --debug dependency add trusch.io/alpine
acbuild --debug copy build/jamesc.arm /bin/jamesc
acbuild --debug set-exec -- /bin/jamesc
acbuild --debug write --overwrite aci/jamesc-${VERSION}-armv7l.aci

yes | gpg --sign --armor --detach -u tino.rusch@gmail.com aci/jamesc-${VERSION}-armv7l.aci

ln -s jamesc-${VERSION}-armv7l.aci aci/jamesc-latest-armv7l.aci
ln -s jamesc-${VERSION}-armv7l.aci.asc aci/jamesc-latest-armv7l.aci.asc

exit $?

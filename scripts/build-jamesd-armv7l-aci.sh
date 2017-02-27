#!/bin/bash

export GOPATH=$(pwd)/build

source scripts/versions.sh

GOOS=linux GOARCH=amd64 go get -d -v gopkg.in/trusch/jamesd.${JAMESD_VERSION}/...
GOOS=linux GOARCH=arm go build -o build/jamesd.arm gopkg.in/trusch/jamesd.${JAMESD_VERSION}/cmd/jamesd
GOOS=linux GOARCH=arm go build -o build/jamesd-ctl.arm gopkg.in/trusch/jamesd.${JAMESD_VERSION}/cmd/jamesd-ctl

VERSION=$(git -C $GOPATH/src/gopkg.in/trusch/jamesd.${JAMESD_VERSION} describe)

acbuild --debug begin

# In the event of the script exiting, end the build
trap "{ export EXT=$?; acbuild --debug end && exit $EXT; }" EXIT

acbuild --debug set-name trusch.io/jamesd

acbuild --debug dependency add trusch.io/alpine
acbuild --debug label add arch armv7l
acbuild --debug label add label ${VERSION}
acbuild --debug copy build/jamesd.arm /bin/jamesd
acbuild --debug copy build/jamesd-ctl.arm /bin/jamesd-ctl
acbuild --debug set-exec -- /bin/jamesd
acbuild --debug write --overwrite aci/jamesd-${VERSION}-armv7l.aci

yes | gpg --sign --armor --detach -u tino.rusch@gmail.com aci/jamesd-${VERSION}-armv7l.aci

ln -s jamesd-${VERSION}-armv7l.aci aci/jamesd-latest-armv7l.aci
ln -s jamesd-${VERSION}-armv7l.aci.asc aci/jamesd-latest-armv7l.aci.asc

exit $?

#!/bin/bash

export GOPATH=$(pwd)/build

source scripts/versions.sh

GOOS=linux GOARCH=arm go get -d -v gopkg.in/trusch/jwtd.${JWTD_VERSION}/...
GOOS=linux GOARCH=arm go build -o build/jwtd.arm gopkg.in/trusch/jwtd.${JWTD_VERSION}
GOOS=linux GOARCH=arm go build -o build/jwtd-ctl.arm gopkg.in/trusch/jwtd.${JWTD_VERSION}/jwtd-ctl

VERSION=$(git -C $GOPATH/src/gopkg.in/trusch/jwtd.${JWTD_VERSION} describe)

acbuild --debug begin

# In the event of the script exiting, end the build
trap "{ export EXT=$?; acbuild --debug end && exit $EXT; }" EXIT

acbuild --debug set-name trusch.io/jwtd
acbuild --debug label add arch armv7l
acbuild --debug label add version ${VERSION}
acbuild --debug dependency add trusch.io/alpine
acbuild --debug copy build/jwtd.arm /bin/jwtd
acbuild --debug copy build/jwtd-ctl.arm /bin/jwtd-ctl
acbuild --debug set-exec -- /bin/jwtd
acbuild --debug write --overwrite aci/jwtd-${VERSION}-armv7l.aci

yes | gpg --sign --armor --detach -u tino.rusch@gmail.com aci/jwtd-${VERSION}-armv7l.aci

ln -s jwtd-${VERSION}-armv7l.aci aci/jwtd-latest-armv7l.aci
ln -s jwtd-${VERSION}-armv7l.aci.asc aci/jwtd-latest-armv7l.aci.asc

exit $?

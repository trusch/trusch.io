#!/bin/bash

source scripts/versions.sh

export GOPATH=$(pwd)/build
GOOS=linux GOARCH=arm go get -d -v gopkg.in/trusch/skydns-pod-announcer.${SKYDNS_POD_ANNOUNCER_VERSION}
GOOS=linux GOARCH=arm go build -o build/skydns-pod-announcer.arm gopkg.in/trusch/skydns-pod-announcer.${SKYDNS_POD_ANNOUNCER_VERSION}

VERSION=$(git -C $GOPATH/src/gopkg.in/trusch/skydns-pod-announcer.${SKYDNS_POD_ANNOUNCER_VERSION} describe)

acbuild --debug begin

# In the event of the script exiting, end the build
trap "{ export EXT=$?; acbuild --debug end && exit $EXT; }" EXIT

acbuild --debug set-name trusch.io/skydns-pod-announcer
acbuild --debug label add arch armv7l
acbuild --debug label add version ${VERSION}
acbuild --debug dependency add trusch.io/alpine
acbuild --debug copy build/skydns-pod-announcer.arm /bin/skydns-pod-announcer
acbuild --debug set-exec -- /bin/skydns-pod-announcer
acbuild --debug write --overwrite aci/skydns-pod-announcer-${VERSION}-armv7l.aci

yes | gpg --sign --armor --detach -u tino.rusch@gmail.com aci/skydns-pod-announcer-${VERSION}-armv7l.aci

ln -s skydns-pod-announcer-${VERSION}-armv7l.aci aci/skydns-pod-announcer-latest-armv7l.aci
ln -s skydns-pod-announcer-${VERSION}-armv7l.aci.asc aci/skydns-pod-announcer-latest-armv7l.aci.asc

exit $?

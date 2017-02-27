#!/bin/bash

source scripts/versions.sh

export GOPATH=$(pwd)/build
GOOS=linux GOARCH=arm go get -d -v github.com/skynetservices/skydns
GOOS=linux GOARCH=arm go build -o build/skydns.arm github.com/skynetservices/skydns

acbuild --debug begin

# In the event of the script exiting, end the build
trap "{ export EXT=$?; acbuild --debug end && exit $EXT; }" EXIT

acbuild --debug set-name trusch.io/skydns
acbuild --debug label add version ${SKYDNS_VERSION}
acbuild --debug label add arch armv7l
acbuild --debug dependency add trusch.io/alpine
acbuild --debug copy build/skydns.arm /bin/skydns
acbuild --debug port add dns tcp 53
acbuild --debug write --overwrite aci/skydns-${SKYDNS_VERSION}-armv7l.aci

yes | gpg --sign --armor --detach -u tino.rusch@gmail.com aci/skydns-${SKYDNS_VERSION}-armv7l.aci

ln -s skydns-${SKYDNS_VERSION}-armv7l.aci aci/skydns-latest-armv7l.aci
ln -s skydns-${SKYDNS_VERSION}-armv7l.aci.asc aci/skydns-latest-armv7l.aci.asc

exit 0

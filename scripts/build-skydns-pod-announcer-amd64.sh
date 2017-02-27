#!/bin/bash

source scripts/versions.sh

export GOPATH=$(pwd)/build
GOOS=linux GOARCH=amd64 go get -d -v gopkg.in/trusch/skydns-pod-announcer.${SKYDNS_POD_ANNOUNCER_VERSION}
GOOS=linux GOARCH=amd64 go build -ldflags '-linkmode external -extldflags -static' -o build/skydns-pod-announcer.amd64 gopkg.in/trusch/skydns-pod-announcer.${SKYDNS_POD_ANNOUNCER_VERSION}

VERSION=$(git -C $GOPATH/src/gopkg.in/trusch/skydns-pod-announcer.${SKYDNS_POD_ANNOUNCER_VERSION} describe)

acbuild --debug begin

# In the event of the script exiting, end the build
trap "{ export EXT=$?; acbuild --debug end && exit $EXT; }" EXIT

acbuild --debug set-name trusch.io/skydns-pod-announcer
acbuild --debug label add version ${VERSION}
acbuild --debug dependency add trusch.io/alpine
acbuild --debug copy build/skydns-pod-announcer.amd64 /bin/skydns-pod-announcer
acbuild --debug set-exec -- /bin/skydns-pod-announcer
acbuild --debug write --overwrite aci/skydns-pod-announcer-${VERSION}-amd64.aci

yes | gpg --sign --armor --detach -u tino.rusch@gmail.com aci/skydns-pod-announcer-${VERSION}-amd64.aci

ln -s skydns-pod-announcer-${VERSION}-amd64.aci aci/skydns-pod-announcer-latest-amd64.aci
ln -s skydns-pod-announcer-${VERSION}-amd64.aci.asc aci/skydns-pod-announcer-latest-amd64.aci.asc

exit $?

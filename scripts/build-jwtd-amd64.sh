#!/bin/bash

export GOPATH=$(pwd)/build

source scripts/versions.sh

GOOS=linux GOARCH=amd64 go get -d -v gopkg.in/trusch/jwtd.${JWTD_VERSION}/...
GOOS=linux GOARCH=amd64 go build -ldflags '-linkmode external -extldflags -static' -o build/jwtd.amd64 gopkg.in/trusch/jwtd.${JWTD_VERSION}
GOOS=linux GOARCH=amd64 go build -ldflags '-linkmode external -extldflags -static' -o build/jwtd-ctl.amd64 gopkg.in/trusch/jwtd.${JWTD_VERSION}/jwtd-ctl

VERSION=$(git -C $GOPATH/src/gopkg.in/trusch/jwtd.${JWTD_VERSION} describe)

acbuild --debug begin

# In the event of the script exiting, end the build
trap "{ export EXT=$?; acbuild --debug end && exit $EXT; }" EXIT

acbuild --debug set-name trusch.io/jwtd
acbuild --debug label add version ${VERSION}
acbuild --debug dependency add trusch.io/alpine
acbuild --debug copy build/jwtd.amd64 /bin/jwtd
acbuild --debug copy build/jwtd-ctl.amd64 /bin/jwtd-ctl
acbuild --debug set-exec -- /bin/jwtd
acbuild --debug write --overwrite aci/jwtd-${VERSION}-amd64.aci

yes | gpg --sign --armor --detach -u tino.rusch@gmail.com aci/jwtd-${VERSION}-amd64.aci

ln -s jwtd-${VERSION}-amd64.aci aci/jwtd-latest-amd64.aci
ln -s jwtd-${VERSION}-amd64.aci.asc aci/jwtd-latest-amd64.aci.asc

exit $?

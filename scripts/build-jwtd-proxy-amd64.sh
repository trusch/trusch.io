#!/bin/bash

export GOPATH=$(pwd)/build

source scripts/versions.sh

GOOS=linux GOARCH=amd64 go get -d -v gopkg.in/trusch/jwtd.${JWTD_VERSION}/...
GOOS=linux GOARCH=amd64 go build -ldflags '-linkmode external -extldflags -static' -o build/jwtd-proxy.amd64 gopkg.in/trusch/jwtd.${JWTD_VERSION}/jwtd-proxy

VERSION=$(git -C $GOPATH/src/gopkg.in/trusch/jwtd.${JWTD_VERSION} describe)

acbuild --debug begin

# In the event of the script exiting, end the build
trap "{ export EXT=$?; acbuild --debug end && exit $EXT; }" EXIT

acbuild --debug set-name trusch.io/jwtd-proxy
acbuild --debug label add version ${VERSION}
acbuild --debug dependency add trusch.io/alpine
acbuild --debug copy build/jwtd-proxy.amd64 /bin/jwtd-proxy
acbuild --debug set-exec -- /bin/jwtd-proxy
acbuild --debug write --overwrite aci/jwtd-proxy-${VERSION}-amd64.aci

yes | gpg --sign --armor --detach -u tino.rusch@gmail.com aci/jwtd-proxy-${VERSION}-amd64.aci

ln -s jwtd-proxy-${VERSION}-amd64.aci aci/jwtd-proxy-latest-amd64.aci
ln -s jwtd-proxy-${VERSION}-amd64.aci.asc aci/jwtd-proxy-latest-amd64.aci.asc

exit $?

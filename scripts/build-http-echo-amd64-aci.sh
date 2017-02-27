#!/bin/bash

export GOPATH=$(pwd)/build

source scripts/versions.sh

GOOS=linux GOARCH=amd64 go get -d -v gopkg.in/trusch/http-echo.${HTTP_ECHO_VERSION}
GOOS=linux GOARCH=amd64 go build -ldflags '-linkmode external -extldflags -static' -o build/http-echo.amd64  gopkg.in/trusch/http-echo.${HTTP_ECHO_VERSION}

VERSION=$(git -C $GOPATH/src/gopkg.in/trusch/http-echo.${HTTP_ECHO_VERSION} describe)

acbuild --debug begin

# In the event of the script exiting, end the build
trap "{ export EXT=$?; acbuild --debug end && exit $EXT; }" EXIT

acbuild --debug set-name trusch.io/http-echo
acbuild --debug label add version ${VERSION}
acbuild --debug dependency add trusch.io/alpine
acbuild --debug copy build/http-echo.amd64 /bin/http-echo
acbuild --debug set-exec -- /bin/http-echo
acbuild --debug write --overwrite aci/http-echo-${VERSION}-amd64.aci

yes | gpg --sign --armor --detach -u tino.rusch@gmail.com aci/http-echo-${VERSION}-amd64.aci

ln -s http-echo-${VERSION}-amd64.aci aci/http-echo-latest-amd64.aci
ln -s http-echo-${VERSION}-amd64.aci.asc aci/http-echo-latest-amd64.aci.asc

exit $?

#!/bin/bash

export GOPATH=$(pwd)/build

source scripts/versions.sh

GOOS=linux GOARCH=arm go get -d -v gopkg.in/trusch/http-echo.${HTTP_ECHO_VERSION}
GOOS=linux GOARCH=arm go build -o build/http-echo.arm gopkg.in/trusch/http-echo.${HTTP_ECHO_VERSION}

VERSION=$(git -C ${GOPATH}/src/gopkg.in/trusch/http-echo.${HTTP_ECHO_VERSION} describe)

acbuild --debug begin

# In the event of the script exiting, end the build
trap "{ export EXT=$?; acbuild --debug end && exit $EXT; }" EXIT

acbuild --debug set-name trusch.io/http-echo
acbuild --debug label add arch armv7l
acbuild --debug label add version ${VERSION}
acbuild --debug dependency add trusch.io/alpine
acbuild --debug copy build/http-echo.arm /bin/http-echo
acbuild --debug set-exec -- /bin/http-echo
acbuild --debug write --overwrite aci/http-echo-${VERSION}-armv7l.aci

yes | gpg --sign --armor --detach -u tino.rusch@gmail.com aci/http-echo-${VERSION}-armv7l.aci

ln -s http-echo-${VERSION}-armv7l.aci aci/http-echo-latest-armv7l.aci
ln -s http-echo-${VERSION}-armv7l.aci.asc aci/http-echo-latest-armv7l.aci.asc

exit $?

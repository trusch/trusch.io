#!/bin/bash

export GOPATH=$(pwd)/build

source scripts/versions.sh

GOOS=linux GOARCH=amd64 go get -d -v gopkg.in/trusch/jamesd.${JAMESD_VERSION}/...
GOOS=linux GOARCH=amd64 go build -ldflags '-linkmode external -extldflags -static' -o build/jamesd.amd64 gopkg.in/trusch/jamesd.${JAMESD_VERSION}/cmd/jamesd
GOOS=linux GOARCH=amd64 go build -ldflags '-linkmode external -extldflags -static' -o build/jamesd-ctl.amd64 gopkg.in/trusch/jamesd.${JAMESD_VERSION}/cmd/jamesd-ctl

VERSION=$(git -C $GOPATH/src/gopkg.in/trusch/jamesd.${JAMESD_VERSION} describe)

acbuild --debug begin

# In the event of the script exiting, end the build
trap "{ export EXT=$?; acbuild --debug end && exit $EXT; }" EXIT

acbuild --debug set-name trusch.io/jamesd
acbuild --debug label add version ${VERSION}
acbuild --debug dependency add trusch.io/alpine
acbuild --debug copy build/jamesd.amd64 /bin/jamesd
acbuild --debug copy build/jamesd-ctl.amd64 /bin/jamesd-ctl
acbuild --debug set-exec -- /bin/jamesd
acbuild --debug write --overwrite aci/jamesd-${VERSION}-amd64.aci

yes | gpg --sign --armor --detach -u tino.rusch@gmail.com aci/jamesd-${VERSION}-amd64.aci

ln -s jamesd-${VERSION}-amd64.aci aci/jamesd-latest-amd64.aci
ln -s jamesd-${VERSION}-amd64.aci.asc aci/jamesd-latest-amd64.aci.asc

exit $?

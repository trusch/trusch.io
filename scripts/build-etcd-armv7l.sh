#!/bin/bash

export GOPATH=$(pwd)/build

source scripts/versions.sh

GOOS=linux GOARCH=arm go get -d -v gopkg.in/coreos/etcd.${ETCD_VERSION}/...
GOOS=linux GOARCH=arm go build -o build/etcd.arm gopkg.in/coreos/etcd.${ETCD_VERSION}
GOOS=linux GOARCH=arm go build -o build/etcdctl.arm gopkg.in/coreos/etcd.${ETCD_VERSION}/etcdctl

VERSION=$(git -C ${GOPATH}/src/gopkg.in/coreos/etcd.${ETCD_VERSION} describe)

acbuild --debug begin

# In the event of the script exiting, end the build
trap "{ export EXT=$?; acbuild --debug end && exit $EXT; }" EXIT

acbuild --debug set-name trusch.io/etcd
acbuild --debug label add arch armv7l
acbuild --debug label add version ${VERSION}
acbuild --debug dependency add trusch.io/alpine
acbuild --debug copy build/etcd.arm /bin/etcd
acbuild --debug copy build/etcdctl.arm /bin/etcdctl
acbuild --debug port add etcd tcp 2379
acbuild --debug write --overwrite aci/etcd-${VERSION}-armv7l.aci

yes | gpg --sign --armor --detach -u tino.rusch@gmail.com aci/etcd-${VERSION}-armv7l.aci

ln -s etcd-${VERSION}-armv7l.aci aci/etcd-latest-armv7l.aci
ln -s etcd-${VERSION}-armv7l.aci.asc aci/etcd-latest-armv7l.aci.asc

exit $?

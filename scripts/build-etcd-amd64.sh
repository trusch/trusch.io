#!/bin/bash

export GOPATH=$(pwd)/build

source scripts/versions.sh

GOOS=linux GOARCH=amd64 go get -d -v gopkg.in/coreos/etcd.${ETCD_VERSION}/...
GOOS=linux GOARCH=amd64 go build -ldflags '-linkmode external -extldflags -static' -o build/etcd.amd64 gopkg.in/coreos/etcd.${ETCD_VERSION}
GOOS=linux GOARCH=amd64 go build -ldflags '-linkmode external -extldflags -static' -o build/etcdctl.amd64 gopkg.in/coreos/etcd.${ETCD_VERSION}/etcdctl

VERSION=$(git -C ${GOPATH}/src/gopkg.in/coreos/etcd.${ETCD_VERSION} describe)

acbuild --debug begin

# In the event of the script exiting, end the build
trap "{ export EXT=$?; acbuild --debug end && exit $EXT; }" EXIT

acbuild --debug set-name trusch.io/etcd
acbuild --debug label add version ${VERSION}
acbuild --debug dependency add trusch.io/alpine
acbuild --debug copy build/etcd.amd64 /bin/etcd
acbuild --debug copy build/etcdctl.amd64 /bin/etcdctl
acbuild --debug port add etcd tcp 2379
acbuild --debug write --overwrite aci/etcd-${VERSION}-amd64.aci

yes | gpg --sign --armor --detach -u tino.rusch@gmail.com aci/etcd-${VERSION}-amd64.aci

ln -s etcd-${VERSION}-amd64.aci aci/etcd-latest-amd64.aci
ln -s etcd-${VERSION}-amd64.aci.asc aci/etcd-latest-amd64.aci.asc

exit $?

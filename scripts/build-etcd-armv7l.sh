#!/bin/bash

export GOPATH=$(pwd)/build

GOOS=linux GOARCH=arm go get -d -v github.com/coreos/etcd/...
GOOS=linux GOARCH=arm go build -o build/etcd.arm github.com/coreos/etcd
GOOS=linux GOARCH=arm go build -o build/etcdctl.arm github.com/coreos/etcd/etcdctl

acbuild --debug begin

# In the event of the script exiting, end the build
trap "{ export EXT=$?; acbuild --debug end && exit $EXT; }" EXIT

acbuild --debug set-name trusch.io/etcd
acbuild --debug label add arch armv7l
acbuild --debug dependency add trusch.io/alpine
acbuild --debug copy build/etcd.arm /bin/etcd
acbuild --debug copy build/etcdctl.arm /bin/etcdctl
acbuild --debug port add etcd tcp 2379
acbuild --debug write --overwrite aci/etcd-armv7l.aci

gpg --sign --armor --detach -u tino.rusch@gmail.com aci/etcd-armv7l.aci

exit $?

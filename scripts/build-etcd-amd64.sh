#!/bin/bash

export GOPATH=$(pwd)/build

GOOS=linux GOARCH=amd64 go get -d -v github.com/coreos/etcd/...
GOOS=linux GOARCH=amd64 go build -ldflags '-linkmode external -extldflags -static' -o build/etcd.amd64 github.com/coreos/etcd
GOOS=linux GOARCH=amd64 go build -ldflags '-linkmode external -extldflags -static' -o build/etcdctl.amd64 github.com/coreos/etcd/etcdctl

acbuild --debug begin

# In the event of the script exiting, end the build
trap "{ export EXT=$?; acbuild --debug end && exit $EXT; }" EXIT

acbuild --debug set-name trusch.io/etcd
acbuild --debug dependency add trusch.io/alpine
acbuild --debug copy build/etcd.amd64 /bin/etcd
acbuild --debug copy build/etcdctl.amd64 /bin/etcdctl
acbuild --debug port add etcd tcp 2379
acbuild --debug write --overwrite aci/etcd-amd64.aci

gpg --sign --armor --detach -u tino.rusch@gmail.com aci/etcd-amd64.aci

exit $?

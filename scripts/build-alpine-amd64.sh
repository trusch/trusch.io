#!/bin/bash

source scripts/versions.sh

rm -rf /tmp/alpine
mkdir -p /tmp/alpine

wget https://nl.alpinelinux.org/alpine/v3.5/releases/x86_64/alpine-minirootfs-${ALPINE_VERSION}-x86_64.tar.gz
tar xfvz alpine-minirootfs-${ALPINE_VERSION}-x86_64.tar.gz -C /tmp/alpine
rm alpine-minirootfs-${ALPINE_VERSION}-x86_64.tar.gz

acbuild --debug begin

# In the event of the script exiting, end the build
trap "{ export EXT=$?; acbuild --debug end && exit $EXT; }" EXIT

acbuild --debug set-name trusch.io/alpine
acbuild --debug label add version ${ALPINE_VERSION}
acbuild --debug copy-to-dir /tmp/alpine/* /
acbuild --debug set-exec -- /bin/sh
acbuild --debug write --overwrite aci/alpine-${ALPINE_VERSION}-amd64.aci

yes | gpg --sign --armor --detach -u tino.rusch@gmail.com aci/alpine-${ALPINE_VERSION}-amd64.aci

ln -s alpine-${ALPINE_VERSION}-amd64.aci aci/alpine-latest-amd64.aci
ln -s alpine-${ALPINE_VERSION}-amd64.aci.asc aci/alpine-latest-amd64.aci.asc

exit 0

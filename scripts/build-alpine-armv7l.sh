#!/bin/bash

source scripts/versions.sh

rm -rf /tmp/alpine
mkdir -p /tmp/alpine

wget https://nl.alpinelinux.org/alpine/v3.5/releases/armhf/alpine-minirootfs-${ALPINE_VERSION}-armhf.tar.gz
tar xfvz alpine-minirootfs-${ALPINE_VERSION}-armhf.tar.gz -C /tmp/alpine
rm alpine-minirootfs-${ALPINE_VERSION}-armhf.tar.gz

acbuild --debug begin

# In the event of the script exiting, end the build
trap "{ export EXT=$?; acbuild --debug end && exit $EXT; }" EXIT

acbuild --debug set-name trusch.io/alpine
acbuild --debug label add version ${ALPINE_VERSION}
acbuild --debug label add arch armv7l
acbuild --debug copy-to-dir /tmp/alpine/* /
acbuild --debug set-exec -- /bin/sh
acbuild --debug write --overwrite aci/alpine-${ALPINE_VERSION}-armv7l.aci

yes | gpg --sign --armor --detach -u tino.rusch@gmail.com aci/alpine-${ALPINE_VERSION}-armv7l.aci

ln -s alpine-${ALPINE_VERSION}-armv7l.aci aci/alpine-latest-armv7l.aci
ln -s alpine-${ALPINE_VERSION}-armv7l.aci.asc aci/alpine-latest-armv7l.aci.asc

exit $?

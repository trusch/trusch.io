#!/bin/bash

rm -rf /tmp/alpine
mkdir -p /tmp/alpine

wget https://nl.alpinelinux.org/alpine/v3.5/releases/armhf/alpine-minirootfs-3.5.0-armhf.tar.gz
tar xfvz alpine-minirootfs-3.5.0-armhf.tar.gz -C /tmp/alpine
rm alpine-minirootfs-3.5.0-armhf.tar.gz

acbuild --debug begin

# In the event of the script exiting, end the build
trap "{ export EXT=$?; acbuild --debug end && exit $EXT; }" EXIT

acbuild --debug set-name trusch.io/alpine
acbuild --debug label add arch armv7l
acbuild --debug copy-to-dir /tmp/alpine/* /
acbuild --debug set-exec -- /bin/sh
acbuild --debug write --overwrite aci/alpine-armv7l.aci

gpg --sign --armor --detach -u tino.rusch@gmail.com aci/alpine-armv7l.aci

exit $?

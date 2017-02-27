#!/bin/bash

source scripts/versions.sh

acbuild --debug begin

# In the event of the script exiting, end the build
trap "{ export EXT=$?; sudo acbuild --debug end && exit $EXT; }" EXIT

acbuild --debug set-name trusch.io/mongodb
acbuild --debug label add version ${MONGODB_VERSION}
acbuild --debug dependency add trusch.io/alpine
sudo acbuild --debug run -- sh -c "echo http://dl-4.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories"
sudo acbuild --debug run -- apk add --no-cache mongodb
sudo acbuild --debug run -- rm /usr/bin/mongosniff /usr/bin/mongoperf
acbuild --debug port add mongo tcp 27017
acbuild --debug mount add data /data/db
acbuild --debug set-exec /usr/bin/mongod
acbuild --debug write --overwrite aci/mongodb-${MONGODB_VERSION}-amd64.aci

yes | gpg --sign --armor --detach -u tino.rusch@gmail.com aci/mongodb-${MONGODB_VERSION}-amd64.aci

ln -s mongodb-${MONGODB_VERSION}-amd64.aci aci/mongodb-latest-amd64.aci
ln -s mongodb-${MONGODB_VERSION}-amd64.aci.asc aci/mongodb-latest-amd64.aci.asc

exit $?

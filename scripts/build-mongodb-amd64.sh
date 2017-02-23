#!/bin/bash

#!/bin/bash

acbuild --debug begin

# In the event of the script exiting, end the build
trap "{ export EXT=$?; sudo acbuild --debug end && exit $EXT; }" EXIT

acbuild --debug set-name trusch.io/mongodb
acbuild --debug dependency add trusch.io/alpine
sudo acbuild --debug run -- sh -c "echo http://dl-4.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories"
sudo acbuild --debug run -- apk add --no-cache mongodb
sudo acbuild --debug run -- rm /usr/bin/mongosniff /usr/bin/mongoperf
acbuild --debug port add mongo tcp 27017
acbuild --debug mount add data /data/db
acbuild --debug set-exec /usr/bin/mongod
acbuild --debug write --overwrite aci/mongodb-amd64.aci

gpg --sign --armor --detach -u tino.rusch@gmail.com aci/mongodb-amd64.aci

exit $?

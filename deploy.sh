#!/bin/bash

rsync --exclude build -avz * .htaccess u88390433@home670566083.1and1-data.host:~/

exit $?

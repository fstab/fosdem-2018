#!/bin/bash

set -x

docker run --rm $(cat Dockerfile | grep EXPOSE | sed -r 's/EXPOSE ([0-9]+)/-p \1:\1/g') -t -i fstab/fosdem-2018

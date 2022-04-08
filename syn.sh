#!/bin/sh

dirs=("config" "unmapped" "mapped" "config" "work" "report" "libs")

for dir in ${dirs[*]}
do
    if [ ! -d ${dir} ] ; then
        mkdir -p ${dir}
    else
        echo "---> Check ${dir} directory"
    fi
done



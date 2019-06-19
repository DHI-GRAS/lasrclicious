#!/bin/bash

if [ $1 == "process" ] ; then
    /bin/bash /usr/local/bin/run_lasrc.sh ${@:2} 
elif [ $1 == "updatelads" ] ; then
    /usr/bin/python /opt/espa-surface-reflectance/build/espa-surface-reflectance/lasrc/bin/updatelads.py ${@:2}
elif [ $1 == "--help" ] ; then
    echo "Usage: process --help or updatelads --help"
    exit 0
else
    echo "Usage: process --help or updatelads --help"
    exit -1
fi

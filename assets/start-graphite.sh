#!/bin/bash

if [[ ! -f /opt/graphite/persistent-storage/initialized ]]; then
    mkdir -p /opt/graphite/persistent-storage
    cp -a /opt/graphite/storage/* /opt/graphite/persistent-storage/
    touch /opt/graphite/persistent-storage/initialized
fi

rm -rf /opt/graphite/storage
cd /opt/graphite/ && ln -s persistent-storage storage

if [[ -f /opt/graphite/storage/carbon-cache-a.pid ]]; then
    rm -f /opt/graphite/storage/carbon-cache-a.pid
fi

/usr/bin/supervisord

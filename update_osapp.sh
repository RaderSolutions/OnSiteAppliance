#!/bin/sh


rm -rf /tmp/osapp
cd /tmp
git clone https://github.com/radersolutions/OnSiteAppliance \
    && rm -rf /usr/local/osapp \
    && mv -f /tmp/osapp /usr/local

echo "Updated"


#!/bin/sh

source /etc/osapp/osapp-vars.conf

vm=$Perch_VMName
virsh destroy --domain $vm
virsh undefine --domain $vm
rm -f /var/lib/libvirt/pool0/*perch*



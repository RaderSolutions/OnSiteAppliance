#!/bin/sh

weekday=$(date +%A)

for vm in $(virsh list --name); do
  echo "Deleting Last Week's Backup (Don't worry if it doesn't exist)"
  snapshot_name="$vm_$weekday"
  virsh snapshot-delete $vm $snapshot_name 
  echo "Creating new snapshot $snapshot_name"
  virsh snapshot-create-as $vm $snapshot_name 
done 


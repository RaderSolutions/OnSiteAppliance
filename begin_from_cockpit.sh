#!/bin/sh

custAbbr=$1
custTld=$2
siteSubnet=$3
siteName=$4
extDns1=$5
extDns2=$6
cybercns_hostname=$7
cybercns_siteId=$8
Perch_URL=$9
OPNSense_URL=${10}
OPNSense_SHA256=${11}

mkdir -p /etc/osapp 
conf="/etc/osapp/osapp-vars.conf"

echo """
osapp_inst=\"/usr/local/osapp\"
vpool=\"pool0\"
nicBondType=\"bond\"
VLAN_IDs=(10 20 30 40 50 60 70 80 100)
OSAPP_Hostname=\"$custAbbr-$siteName-OSAPP\"
Perch_Hostname=\"$custAbbr-$siteName-Perch\"
OPNsense_Hostname=\"$custAbbr-$siteName-FW\"
OPNSense_VMName=\"OPNsense_Firewall\"
Perch_VMName=\"Perch_Sensor\"
custAbbr=\"$custAbbr\"
custTld=\"$custTld\"
siteSubnet=\"$siteSubnet\"
Allowed_DNS=(\"$extDns1\" \"$extDns2\")
cybercns_hostname=\"$cybercns_hostname\"
cybercns_siteId=\"$cybercns_siteId\"
Perch_URL=\"$Perch_URL\"
OPNSense_URL=\"$OPNSense_URL\"
OPNSense_SHA256=\"$OPNSense_SHA256\"
""" > $conf 

tmpScript="/usr/local/bin/run-osapp-setup.sh"
rm -f $tmpScript 
echo '#!/bin/sh

touch /tmp/osapp-setup-running

source /etc/osapp/osapp-vars.conf 
echo "Beginning Setup"

# Install OS addons
dnf -y install epel-release
dnf -y install cockpit-dashboard cockpit-machine cockpit-session-recording

cat /dev/zero | ssh-keygen -t rsa -q -N ""

# Set up Hypervisor
/usr/local/osapp/host_setup/host_kvm_setup.sh

# Set up Networking
/usr/local/osapp/host_setup/host_networking.sh

# Import Firewall VM(s)
/usr/local/osapp/vm_setup/opnsense/create_opnsense.sh

# Import Perch VM
/usr/local/osapp/vm_setup/perch/create_perch.sh

# Configure Firewall VM
/usr/local/osapp/vm_setup/opnsense/process_config.sh 

# Boot Perch VM 
/usr/local/osapp/vm_setup/perch/start_perch.sh 

### Ready for Containers ### 
/usr/local/osapp/container_setup/podman.sh

# Create CyberCNS Container if needed
if [[ $(echo $cybercns_siteId) -eq 25 ]]; then 
    /usr/local/osapp/container_setup/cybercns/cybercns.sh 
fi

echo "End Setup."
rm -f /tmp/osapp-setup-running
' > $tmpScript

chmod a+x $tmpScript 
unitid="OSAPP-Setup-${RANDOM}"
echo "Starting job: watch with journalctl -f -u $unitid"
echo ""
systemd-run --unit=$unitid $tmpScript
journalctl -f -u $unitid



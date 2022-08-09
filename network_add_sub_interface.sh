ifwan=eno1
array=('Sub_192.168.201.0|301' 'Sub_192.168.202.0|302')
for i in ${array[@]}
do
IFS='|' read subnet vlan <<< "$i"

prlsrvctl net add $subnet
vconfig add $ifwan $vlan

cat > /etc/sysconfig/network-scripts/ifcfg-$ifwan.$vlan << EOF
VLAN=yes
TYPE=Vlan
DEVICE=$ifwan.$vlan
PHYSDEV=$ifwan
VLAN_ID=$vlan
REORDER_HDR=yes
GVRP=no
MVRP=no
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
NAME=$ifwan.$vlan
ONBOOT=yes
BRIDGE=br-$ifwan.$vlan
EOF

brctl addbr br-$ifwan.$vlan
brctl addif br-$ifwan.$vlan $ifwan.$vlan

cat > /etc/sysconfig/network-scripts/ifcfg-br-$ifwan.$vlan << EOF
DEVICE=br-$ifwan.$vlan
STP=no
TYPE=Bridge
BOOTPROTO=autoip
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=no
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=br-$ifwan.$vlan
ONBOOT=yes
EOF

ifup br-$ifwan.$vlan
ifdown br-$ifwan.$vlan
ifup $ifwan.$vlan
ifup br-$ifwan.$vlan
prlsrvctl net set $subnet -t bridged -i $ifwan.$vlan
done
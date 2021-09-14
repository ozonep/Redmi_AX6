#!/bin/bash

sed -i 's/10.10.10.1/192.168.30.1/g' package/base-files/files/bin/config_generate

sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=65535' package/base-files/files/etc/sysctl.conf

sed -i 's/CST-8/MSK-3/g' package/lean/default-settings/files/zzz-default-settings
sed -i 's/Asia\/Shanghai/Europe\/Moscow/g' package/lean/default-settings/files/zzz-default-settings

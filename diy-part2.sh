#!/bin/bash

sed -i 's/10.10.10.1/192.168.30.1/g' package/base-files/files/bin/config_generate

sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=65535' package/base-files/files/etc/sysctl.conf

sed -i 's/OpenWrt_2.4G/OpenWrt_5G/g'  package/kernel/mac80211/files/lib/wifi/mac80211.sh
sed -i '185s/OpenWrt_5G/OpenWrt_2.4G/' package/kernel/mac80211/files/lib/wifi/mac80211.sh

rm -rf package/lean/luci-app-ttyd
rm -rf feeds/packages/utils/ttyd
rm -rf package/lean/luci-theme-argon
rm -rf feeds/Boos/wrtbwmon 
rm -rf feeds/Boos/luci-app-ssr-plus 
rm -rf feeds/Boos/luci-app-passwall 
rm -rf feeds/Boos/luci-app-passwall-plus 
rm -rf feeds/Boos/luci-app-wrtbwmon


#! /bin/sh

eval `dbus export ss`
alias echo_date='echo $(date +%Y年%m月%d日\ %X):'
mkdir -p /koolshare/ss

# 判断路由架构和平台
case $(uname -m) in
  armv7l)
	echo_date 固件平台【koolshare merlin armv7l】符合安装要求，开始安装插件！
    ;;
  mips)
  	echo_date 本插件适用于koolshare merlin armv7l固件平台，mips平台不能安装！！！
  	echo_date 退出安装！
    exit 0
    ;;
  x86_64)
	echo_date 本插件适用于koolshare merlin armv7l固件平台，x86_64固件平台不能安装！！！
	exit 0
    ;;
  *)
  	echo_date 本插件适用于koolshare merlin armv7l固件平台，其它平台不能安装！！！
  	echo_date 退出安装！
    exit 0
    ;;
esac

upgrade_ss_conf(){
	nodes=`dbus list ssc|grep port|cut -d "=" -f1|cut -d "_" -f4|sort -n`
	for node in $nodes
	do
		if [ "`dbus get ssconf_basic_use_rss_$node`" == "1" ];then
			#ssr
			dbus remove ssconf_basic_ss_obfs_$node
			dbus remove ssconf_basic_ss_obfs_host_$node
			dbus remove ssconf_basic_koolgame_udp_$node
		else
			if [ -n "`dbus get ssconf_basic_koolgame_udp_$node`" ];then
				#koolgame
				dbus remove ssconf_basic_rss_protocol_$node
				dbus remove ssconf_basic_rss_protocol_param_$node
				dbus remove ssconf_basic_rss_obfs_$node
				dbus remove ssconf_basic_rss_obfs_param_$node
				dbus remove ssconf_basic_ss_obfs_$node
				dbus remove ssconf_basic_ss_obfs_host_$node
			else
				#ss
				dbus remove ssconf_basic_rss_protocol_$node
				dbus remove ssconf_basic_rss_protocol_param_$node
				dbus remove ssconf_basic_rss_obfs_$node
				dbus remove ssconf_basic_rss_obfs_param_$node
				dbus remove ssconf_basic_koolgame_udp_$node
				[ -z "`dbus get ssconf_basic_ss_obfs_$node`" ] && dbus set ssconf_basic_ss_obfs_$node="0"
			fi
		fi
		dbus remove ssconf_basic_use_rss_$node
	done
	
	use_node=`dbus get ssconf_basic_node`
	[ -z "$use_node" ] && use_node="1"
	dbus remove ss_basic_server
	dbus remove ss_basic_mode
	dbus remove ss_basic_port
	dbus remove ss_basic_method
	dbus remove ss_basic_ss_obfs
	dbus remove ss_basic_ss_obfs_host
	dbus remove ss_basic_rss_protocol
	dbus remove ss_basic_rss_protocol_param
	dbus remove ss_basic_rss_obfs
	dbus remove ss_basic_rss_obfs_param
	dbus remove ss_basic_koolgame_udp
	dbus remove ss_basic_use_rss
	dbus remove ss_basic_use_kcp
	sleep 1
	[ -n "`dbus get ssconf_basic_server_$node`" ] && dbus set ss_basic_server=`dbus get ssconf_basic_server_$node`
	[ -n "`dbus get ssconf_basic_mode_$node`" ] && dbus set ss_basic_mode=`dbus get ssconf_basic_mode_$node`
	[ -n "`dbus get ssconf_basic_port_$node`" ] && dbus set ss_basic_port=`dbus get ssconf_basic_port_$node`
	[ -n "`dbus get ssconf_basic_method_$node`" ] && dbus set ss_basic_method=`dbus get ssconf_basic_method_$node`
	[ -n "`dbus get ssconf_basic_ss_obfs_$node`" ] && dbus set ss_basic_ss_obfs=`dbus get ssconf_basic_ss_obfs_$node`
	[ -n "`dbus get ssconf_basic_ss_obfs_host_$node`" ] && dbus set ss_basic_ss_obfs_host=`dbus get ssconf_basic_ss_obfs_host_$node`
	[ -n "`dbus get ssconf_basic_rss_protocol_$node`" ] && dbus set ss_basic_rss_protocol=`dbus get ssconf_basic_rss_protocol_$node`
	[ -n "`dbus get ssconf_basic_rss_protocol_param_$node`" ] && dbus set ss_basic_rss_protocol_param=`dbus get ssconf_basic_rss_protocol_param_$node`
	[ -n "`dbus get ssconf_basic_rss_obfs_$node`" ] && dbus set ss_basic_rss_obfs=`dbus get ssconf_basic_rss_obfs_$node`
	[ -n "`dbus get ssconf_basic_rss_obfs_param_$node`" ] && dbus set ss_basic_rss_obfs_param=`dbus get ssconf_basic_rss_obfs_param_$node`
	[ -n "`dbus get ssconf_basic_koolgame_udp_$node`" ] && dbus set ss_basic_koolgame_udp=`dbus get ssconf_basic_koolgame_udp_$node`
	[ -n "`dbus get ssconf_basic_use_kcp_$node`" ] && dbus set ss_basic_koolgame_udp=`dbus get ssconf_basic_use_kcp_$node`
}

SS_VERSION_OLD=`dbus get ss_basic_version_local`
[ -z "$SS_VERSION_OLD" ] && SS_VERSION_OLD=3.6.5
ss_comp=`versioncmp $SS_VERSION_OLD 3.6.5`
if [ -n "$SS_VERSION_OLD" ];then
	if [ "$ss_comp" == "1" ];then
		echo_date ！！！！！！！！！！！！！！！！！！！！！！！！！！!
		echo_date 检测到SS版本号为 $SS_VERSION_OLD !
		echo_date 从3.6.5开始，SS插件和之前版本的数据格式不完全兼容 !
		echo_date 此次升级将会尝试升级原先的数据 !
		echo_date 如果你安装此版本后仍然有问题，请尝试清空ss数据后重新录入 !
		echo_date ！！！！！！！！！！！！！！！！！！！！！！！！！！!
		upgrade_ss_conf
	fi
fi

# 先关闭ss
if [ "$ss_basic_enable" == "1" ];then
	echo_date 先关闭ss，保证文件更新成功!
	[ -f "/koolshare/ss/stop.sh" ] && sh /koolshare/ss/stop.sh stop_all || sh /koolshare/ss/ssconfig.sh stop
fi

#升级前先删除无关文件
echo_date 清理旧文件
rm -rf /koolshare/ss/*
rm -rf /koolshare/scripts/ss_*
rm -rf /koolshare/webs/Main_Ss*
rm -rf /koolshare/bin/ss-*
rm -rf /koolshare/bin/rss-*
rm -rf /koolshare/bin/obfs*
rm -rf /koolshare/bin/haproxy
rm -rf /koolshare/bin/redsocks2
rm -rf /koolshare/bin/pdnsd
rm -rf /koolshare/bin/Pcap_DNSProxy
rm -rf /koolshare/bin/dnscrypt-proxy
rm -rf /koolshare/bin/dns2socks
rm -rf /koolshare/bin/client_linux_arm5
rm -rf /koolshare/bin/chinadns
rm -rf /koolshare/bin/resolveip
rm -rf /koolshare/res/layer
rm -rf /koolshare/res/shadowsocks.css
rm -rf /koolshare/res/icon-shadowsocks.png
rm -rf /koolshare/res/ss-menu.js
rm -rf /koolshare/res/all.png
rm -rf /koolshare/res/gfwlist.png
rm -rf /koolshare/res/chn.png
rm -rf /koolshare/res/game.png
rm -rf /koolshare/res/shadowsocks.css
rm -rf /koolshare/res/gameV2.png
rm -rf /koolshare/res/ss_proc_status.htm

echo_date 开始复制文件！
cd /tmp

echo_date 复制相关二进制文件！
cp -rf /tmp/shadowsocks/bin/* /koolshare/bin/
chmod 755 /koolshare/bin/*

echo_date 创建一些二进制文件的软链接！
[ ! -L "/koolshare/bin/rss-tunnel" ] && ln -sf /koolshare/bin/rss-local /koolshare/bin/rss-tunnel
[ ! -L "/koolshare/bin/base64" ] && ln -sf /koolshare/bin/koolbox /koolshare/bin/base64
[ ! -L "/koolshare/bin/shuf" ] && ln -sf /koolshare/bin/koolbox /koolshare/bin/shuf
[ ! -L "/koolshare/bin/netstat" ] && ln -sf /koolshare/bin/koolbox /koolshare/bin/netstat
[ ! -L "/koolshare/bin/base64_decode" ] && ln -s /koolshare/bin/base64_encode /koolshare/bin/base64_decode

echo_date 复制ss的脚本文件！
cp -rf /tmp/shadowsocks/ss/* /koolshare/ss/
cp -rf /tmp/shadowsocks/scripts/* /koolshare/scripts/
cp -rf /tmp/shadowsocks/install.sh /koolshare/scripts/ss_install.sh
cp -rf /tmp/shadowsocks/uninstall.sh /koolshare/scripts/uninstall_shadowsocks.sh
cp -rf /tmp/shadowsocks/init.d/* /koolshare/init.d/

echo_date 复制网页文件！
cp -rf /tmp/shadowsocks/webs/* /koolshare/webs/
cp -rf /tmp/shadowsocks/res/* /koolshare/res/

echo_date 移除安装包！
rm -rf /tmp/shadowsocks* >/dev/null 2>&1

echo_date 为新安装文件赋予执行权限...
chmod 755 /koolshare/ss/koolgame/*
chmod 755 /koolshare/ss/cru/*
chmod 755 /koolshare/ss/rules/*
chmod 755 /koolshare/ss/dns/*
chmod 755 /koolshare/ss/socks5/*
chmod 755 /koolshare/ss/*
chmod 755 /koolshare/scripts/ss*
chmod 755 /koolshare/bin/*

# 设置一些默认值
echo_date 设置一些默认值
[ -z "$ss_dns_china" ] && dbus set ss_dns_china=11
[ -z "$ss_dns_foreign" ] && dbus set ss_dns_foreign=1
[ -z "$ss_basic_ss_obfs" ] && dbus set ss_basic_ss_obfs=0
[ -z "$ss_acl_default_mode" ] && [ -n "$ss_basic_mode" ] && dbus set ss_acl_default_mode="$ss_basic_mode"
[ -z "$ss_acl_default_mode" ] && [ -z "$ss_basic_mode" ] && dbus set ss_acl_default_mode=1
[ -z "$ss_acl_default_port" ] && dbus set ss_acl_default_port=all
[ -z "$ss_dns_plan" ] && dbus set ss_dns_china=2

# 离线安装时设置软件中心内储存的版本号和连接
CUR_VERSION=`cat /koolshare/ss/version`
dbus set softcenter_module_shadowsocks_install=1
dbus set softcenter_module_shadowsocks_version="$CUR_VERSION"
dbus set softcenter_module_shadowsocks_title="科学上网"
dbus set softcenter_module_shadowsocks_description="科学上网"
dbus set softcenter_module_shadowsocks_home_url=Main_Ss_Content.asp

sleep 2
echo_date 一点点清理工作...
rm -rf /tmp/shadowsocks* >/dev/null 2>&1
dbus set ss_basic_install_status="0"
echo_date 插件安装成功，你为什么这么屌？！

if [ "$ss_basic_enable" == "1" ];then
	echo_date 重启ss！
	dbus set ss_basic_action=1
	. /koolshare/ss/ssconfig.sh restart
fi
echo_date 更新完毕，请等待网页自动刷新！

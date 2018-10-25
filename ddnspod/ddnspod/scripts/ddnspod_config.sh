#!/bin/sh
source /koolshare/scripts/base.sh
eval `dbus export ddnspod`
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
# ====================================函数定义====================================
# 获得外网地址
arIpAdress() {
    local inter=$(cru(){
	sed -i '/ddnspod/d' /var/spool/cron/crontabs/* >/dev/null 2>&1
	cru a ddnspod "0 */$ddnspod_refresh_time * * * /koolshare/scripts/ddnspod_config.sh update"
}

stop_ddnspod(){
	sed -i '/ddnspod/d' /var/spool/cron/crontabs/* >/dev/null 2>&1
}

# ====================================used by init or cru====================================
case $1 in
start)
	#此处为开机自启动设计
	if [ "$ddnspod_enable" == "1" ];then
		logger "[软件中心]: 启动ddnspod！"
		add_ddnspod_cru
		parseDomain
		arDdnsCheck $mainDomain $subDomain
	else
		logger "[软件中心]: ddnspod未设置开机启动，跳过！"
	fi
	;;
stop | kill )
	#此处卸载插件时关闭插件设计
	stop_ddnspod
	;;
update)
	#此处为定时脚本设计
	parseDomain
	arDdnsCheck $mainDomain $subDomain
	;;
esac
# ====================================submit by web====================================
case $2 in
1)
	#此处为web提交动设计
	if [ "$ddnspod_enable" == "1" ];then
		[ ! -L "/koolshare/init.d/S99ddnspod.sh" ] && ln -sf /koolshare/scripts/ddnspod_config.sh /koolshare/init.d/S99ddnspod.sh
		parseDomain
		add_ddnspod_cru
		arDdnsCheck $mainDomain $subDomain
		http_response "$1"
	else
		stop_ddnspod
		http_response "$1"
	fi
	;;
esac

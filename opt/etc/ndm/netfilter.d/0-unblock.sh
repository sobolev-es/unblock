#!/bin/sh

if [ "$1" == "start" ] ; then
	if [ "$table" == "mangle" ] ; then
		/opt/etc/init.d/S60unblock set_tproxy_rule
	elif [ "$table" == "nat" ] ; then
		/opt/etc/init.d/S60unblock set_redirect_rule
	fi
fi

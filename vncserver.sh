#!/bin/sh
exec /sbin/setuser developer /home/developer/.vnc/vnc.sh >>/var/log/vncserver.log 2>&1
#!/usr/bin/busybox sh

#QNX: we don't have this right now but may in the future
[ -e /usr/bin/bbsuid ] && /bin/bbsuid --install -s /usr/bin
[ -e /usr/bin/busybox-extras ] && /bin/busybox-extras --install -s /usr/bin

/usr/bin/busybox --install -s /usr/bin

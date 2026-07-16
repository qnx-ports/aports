#!/bin/busybox sh

#QNX: we don't have this right now but may in the future
[ -e /bin/bbsuid ] && /bin/bbsuid --install
[ -e /bin/busybox-extras ] && /bin/busybox-extras --install -s

/bin/busybox --install -s

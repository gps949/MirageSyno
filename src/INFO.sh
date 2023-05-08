#! /usr/bin/env bash

VERSION=$1
ARCH=$2
PKG_SIZE=$3
DSM_VERSION=$4

TIMESTAMP=$(date -u +%Y%m%d-%H:%M:%S)

if [ "$DSM_VERSION" = "6" ]; then
  os_min_ver="6.0.1-7445"
  os_max_ver="7.0-40000"
else
  os_min_ver="7.0-40000"
  os_max_ver=""
fi

cat <<EOF
package="Mirage"
version="${VERSION}"
arch="${ARCH}"
description="Connect all your devices using WireGuard, without the hassle."
displayname="Mirage"
maintainer="Mirage Team"
maintainer_url="https://github.com/gps949/MirageSyno"
create_time="${TIMESTAMP}"
dsmuidir="ui"
dsmappname="SYNO.SDS.Mirage"
startstop_restart_services="nginx"
os_min_ver="${os_min_ver}"
os_max_ver="${os_max_ver}"
extractsize="${PKG_SIZE}"
EOF

#!/bin/env bash
set -eo pipefail
cd /opt
[[ -e observium_old ]] && rm -rf observium_old
mv observium observium_old
wget -Oobservium-community-latest.tar.gz https://www.observium.org/observium-community-latest.tar.gz
tar zxvf observium-community-latest.tar.gz
mv /opt/observium_old/rrd observium/
mv /opt/observium_old/logs observium/
mv /opt/observium_old/config.php observium/

/opt/observium/discovery.php -u
/opt/observium/discovery.php -h all

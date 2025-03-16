#!/bin/env bash
# FROM https://www.fuzzygrim.com/posts/upgrade-homelab-os at 10.03.2025
# FROM https://www.turnkeylinux.org/forum/support/sat-20240504-1704/error-500-cannot-login-gitlab-18#comment-57487 at 10.05.2025
set -eo pipefail

CODENAME=bullseye
key_dir=/usr/share/keyrings
base_url=https://github.com/turnkeylinux/common/tree/17.x/overlays/bootstrap_apt
repos=(main security testing)
for repo in ${repos[@]}; do
	local_path=$key_dir/tkl-$CODENAME-$repo
	keyring=$local_path.gpg
	keyfile=$local_path.asc
	key_url=${base_url}${keyfile}
	wget -O $keyfile $key_url
	gpg --no-default-keyring --keyring $keyring --import $keyfile
	rm $keyfile
done

find /etc/apt/sources.list.d/ -type f -exec sed -i 's/buster/bullseye/g' {} \;

sed -i 's/bullseye\/updates/bullseye-security/g' /etc/apt/sources.list.d/security.sources.list

apt update
apt upgrade --without-new-pkgs

apt full-upgrade

echo "Reboot now!!"

exit 0

# Second step for Gitlab

apt install gitlab-ce=15.3.5-ce.0
gitlab-ctl reconfigure

gitlab-rake db:migrate
gitlab-rake gitlab:background_migrations:finalize[ProjectNamespaces::BackfillProjectNamespaces,projects,id,'[null\,"up"]']
gitlab-ctl reconfigure

# Upgrade to Debian 12
git clone https://github.com/turnkeylinux/common.git /tmp/common
CODENAME=bookworm
key_dir=/usr/share/keyrings
base_url=/tmp/common/overlays/bootstrap_apt
repos=(main security testing)
for repo in ${repos[@]}; do
	local_path=$key_dir/tkl-$CODENAME-$repo
	keyring=$local_path.gpg
	keyfile=$local_path.asc
	key_url=${base_url}${keyfile}
	cp $key_url $keyfile
	gpg --no-default-keyring --keyring $keyring --import $keyfile
	rm $keyfile
done
rm -r /tmp/common

find /etc/apt/sources.list.d/ -type f -exec sed -i 's/bullseye/bookworm/g' {} \;

sed -i 's/bookworm\/updates/bookworm-security/g' /etc/apt/sources.list.d/security.sources.list

apt update
apt upgrade --without-new-pkgs

apt full-upgrade

# See https://forum.proxmox.com/threads/installing-gitlab-into-lxc-container-sysctl-kernel-shmmax.49388/post-589744
cat <<EOF | tee -a /etc/gitlab/gitlab.rb
package['modify_kernel_parameters'] = false
EOF

#!/bin/env bash
set -eo

############# certmanager

ROOT_DOMAIN=sterk-bodensee.de

apt update
apt install -y -q python3 python3-venv libaugeas0 nginx vim ufw fail2ban

ufw default deny incoming
ufw allow proto tcp from 192.168.5.0/24 to any port 22
ufw allow https
ufw allow http
yes | ufw enable
ufw status

python3 -m venv /opt/certbot/
/opt/certbot/bin/pip install --upgrade pip
pip install certbot certbot-nginx
ln -s /opt/certbot/bin/certbot /usr/bin/certbot

systemctl enable --now nginx
touch /etc/nginx/sites-available/$ROOT_DOMAIN
cat <<EOF | tee /etc/nginx/sites-available/$ROOT_DOMAIN
server {

    root /var/www/$ROOT_DOMAIN/html;

    server_name $ROOT_DOMAIN;

    location / {
        try_files $uri $uri/ =404;
    }
}
EOF

nginx -t
ln -s /etc/nginx/sites-available/$ROOT_DOMAIN /etc/nginx/sites-enabled/


mkdir -p /var/www/$ROOT_DOMAIN/html
# mkdir -p /var/www/$ROOT_DOMAIN/html/.well/known/acme-challenge/

systemctl restart nginx.service

# certbot certonly --webroot -w /var/www/$ROOT_DOMAIN/ -d $ROOT_DOMAIN
# certbot --nginx -d $ROOT_DOMAIN
certbot run --cert-name $ROOT_DOMAIN -a manual -d "$ROOT_DOMAIN,*.$ROOT_DOMAIN" -i nginx --keep

############# pihole

cat /etc/letsencrypt/live/ssl/cert.pem /etc/letsencrypt/live/ssl/privkey.pem > /etc/letsencrypt/live/ssl/combined.pem

cat <<EOF | tee /etc/lighttpd/external.conf
server.modules += (
  "mod_openssl"
)

setenv.add-environment = ("fqdn" => "true")

\$SERVER["socket"] == ":443" {
    ssl.engine = "enable"
    ssl.pemfile = "/etc/letsencrypt/live/ssl/combined.pem" # Combined Certificate
    ssl.ca-file = "/etc/letsencrypt/live/ssl/chain.pem" # Root CA
    server.name = "tiamat.sterk-bodensee.de" # Domain Name OR Virtual Host Name
}

# Redirect HTTP to HTTPS
\$HTTP["scheme"] == "http" {
	\$HTTP["host"] =~ ".*" {
		url.redirect = (".*" => "https://%0\$0")
	}
}

EOF

apt-get install lighttpd-mod-openssl

systemctl restart lighttpd.service

############# docker

docker stop portainer

docker container rm portainer

docker run -d -p 8000:8000 -p 9443:9443 --name=portainer --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data \
    -v "/etc/letsencrypt/live/ssl/:/certs:ro" \
    portainer/portainer-ce:latest --sslcert /certs/cert.pem --sslkey /certs/privkey.pem

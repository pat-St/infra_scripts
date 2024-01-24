#!/bin/env bash

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

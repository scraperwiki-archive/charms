# warning: shell used as a templating engine!
DEV=${DEV:-true}

cat <<EOF
# Move to common file
gzip_disable msie6;
gzip_static on;
gzip_comp_level 7;
gzip_proxied any;
gzip_types text/plain text/css application/x-javascript text/xml application/xml application/xml+rss text/javascript;

$(if ! $DEV ; then cat <<EOF
# Redirect http on live site to https
server {
  server_name beta.scraperwiki.com;
  listen 80;
  rewrite ^(.*) https://beta.scraperwiki.com\$1 permanent;
}

# Redirect http on live site to https
server {
  server_name scraperwiki.com;
  listen 80;
  rewrite ^(.*) https://scraperwiki.com\$1 permanent;
}

# Redirect www, x to scraperwiki.com
server {
  server_name x.scraperwiki.com www.scraperwiki.com;
  listen 80;
  listen 443 ssl;
  ssl_certificate      star_scraperwiki_com.crt;
  ssl_certificate_key  star_scraperwiki_com.key;
  rewrite ^(.*) https://scraperwiki.com\$1 permanent;
}
EOF
fi)

server {
  include mime.types;

  listen 443 ssl default_server;
$(if $DEV ; then cat <<EOF
  listen 80 default_server;
EOF
fi)
$(if $DEV ; then cat <<EOF
  server_name beta-dev.scraperwiki.com;
EOF
else cat <<EOF
  server_name beta.scraperwiki.com scraperwiki.com;
EOF
fi)
  ssl_certificate      star_scraperwiki_com.crt;
  ssl_certificate_key  star_scraperwiki_com.key;

  error_log /var/log/nginx/error.log warn;
  error_page 502 503 504 /template/50x.html;

  location ~ '^\/(vendor|js|style|image|template)\/(.+)' {
    root /opt/custard/shared;
  }

$(if ! $DEV ; then cat <<EOF
  location ~ '^\/code/' {
    root /opt/custard/builtAssets;
    expires max;
  }
EOF
fi)

  # Redirects to professional services
  rewrite ^/(dataservices|data_hub|business|data_consultancy|dataconsulting) /professional/ permanent;

  # Redirects to Classic
  rewrite ^/browse https://classic.scraperwiki.com/browse/ permanent;
  rewrite ^/jobs https://classic.scraperwiki.com/jobs/ permanent;
  rewrite ^/events https://classic.scraperwiki.com/events/ permanent;
  rewrite ^/tags https://classic.scraperwiki.com/tags/ permanent;
  rewrite ^/scrapers/(.+) https://classic.scraperwiki.com/scrapers/\$1 permanent;
  rewrite ^/views/(.+) https://classic.scraperwiki.com/views/\$1 permanent;
  rewrite ^/profiles/(.+) https://classic.scraperwiki.com/profiles/\$1 permanent;
  rewrite ^/docs([/].+)? https://classic.scraperwiki.com/docs\$1 permanent;
  rewrite ^/editor/raw/(.+) https://classic.scraperwiki.com/editor/raw/\$1 permanent;
  rewrite ^/accounts/(.+) https://classic.scraperwiki.com/accounts/\$1 permanent;


  location /sitemap.txt {
    alias /opt/custard/shared/sitemap.txt;
  }

  location / {
    proxy_pass http://unix:/var/run/custard/custard.socket;
    proxy_set_header X-Real-Port \$remote_port;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Server-IP \$server_addr;
    proxy_set_header X-Server-Port \$server_port;
    proxy_set_header Host \$host;
  }

}
EOF

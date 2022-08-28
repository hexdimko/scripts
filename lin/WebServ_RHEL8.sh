#!/bin/bash
echo "Installing required packages"
yum -y install nginx
yum -y install yum-utils epel-release
dnf install -y https://rpms.remirepo.net/enterprise/remi-release-8.rpm
dnf module install -y php:remi-7.4						
yum -y install php-fpm php-mysql php-zip php-devel php-gd php-mcrypt php-mbstring php-curl php-xml php-pear php-bcmath php-json php-pdo php-pecl-apcu php-pecl-apcu-devel php-pgsql 
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php.ini
sed -i "s/user = apache/user = nginx/g" /etc/php-fpm.d/www.conf
sed -i "s/group = apache/group = nginx/g" /etc/php-fpm.d/www.conf
sed -i "s/;listen.owner = nobody/listen.owner  = nginx/g" /etc/php-fpm.d/www.conf
sed -i "s/;listen.group = nobody/listen.group  = nginx/g" /etc/php-fpm.d/www.conf
sed -i "s/;listen.mode = 0660/listen.mode  = 0660/g" /etc/php-fpm.d/www.conf
echo "Creating php-fpm config"
cat > /etc/nginx/conf.d/php-fpm.conf <<EOF
# PHP-FPM Configuration Nginx
        location ~ \.php\$ {
            try_files \$uri =404;
            fastcgi_split_path_info ^(.+\.php)(/.+)\$;
            fastcgi_pass unix:/run/php-fpm/www.sock;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
            fastcgi_param REMOTE_USER \$remote_user;
            include fastcgi_params;
		}
EOF
mkdir /etc/nginx/sites
mkdir /home/www/
mkdir /home/www/testsite.loc
echo "Creating testsite config"
cat > /etc/nginx/sites/testsite.loc.conf <<EOF
server {
	listen 80;
	#server_name	testsite.loc;
	root	/home/www/testsite.loc;
	index	index.php;
	include /etc/nginx/conf.d/php-fpm.conf;
}
EOF
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf_bak
rm	/etc/nginx/nginx.conf
echo "Creating nginx config"
cat > /etc/nginx/nginx.conf <<EOF
# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Official Russian Documentation: http://nginx.org/ru/docs/

user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';
    access_log  /var/log/nginx/access.log  main;
    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;
    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;
    include /etc/nginx/sites/*.conf;
}
EOF
cat > /home/www/testsite.loc/index.php <<EOF
<?php phpinfo(); ?>
EOF
firewall-cmd --add-service=http --permanent
firewall-cmd --add-service=https --permanent
firewall-cmd --reload
echo "Starting services"
systemctl enable php-fpm
systemctl enable nginx
systemctl start php-fpm
systemctl start nginx
systemctl status php-fpm
systemctl status nginx
echo "WebServer install complete"
echo "Ensure that SELINUX is disabled and try web on:"; hostname -I

FROM ubuntu:20.04
MAINTAINER Huy Nguyen "tronghuy02@gmail.com"
ENV TZ Asia/Ho_Chi_Minh
ENV JOB "*/5 * * * * php /opt/cacti/poller.php"

#update container OS
RUN apt-get update && echo $TZ > /etc/timezone && apt-get install -yq --no-install-recommends mariadb-server mariadb-client php build-essential automake \
                                                            apache2 snmp libapache2-mod-php libssl-dev vim \
                                                            rrdtool librrds-perl php-mysql php-pear \
                                                            php-common php-json php-gettext libtool \
                                                            php-pspell php-recode php-tidy php-xmlrpc \
                                                            php-xml php-ldap php-mbstring php-intl \
                                                            php-gd php-snmp php-gmp php-curl php-net-socket\
                                                            libmysqlclient-dev libsnmp-dev dos2unix help2man git \
                                                            snmpd python-netsnmp libnet-snmp-perl snmp-mibs-downloader \
                                                            iputils-ping autoconf unzip \
                                                && mkdir /opt/cacti \
												&& cd /opt/cacti \
												&& wget https://www.cacti.net/downloads/cacti-latest.tar.gz \
												&& ver=$(tar -tf cacti-latest.tar.gz | head -n1 | tr -d /) \
                                                && tar -xvf cacti-latest.tar.gz && mv $ver cacti \
                                                && rm cacti-latest.tar.gz \
                                                && apt-get clean \
                                                && rm -rf /tmp/* /var/tmp/*  \
                                                && rm -rf /var/lib/apt/lists/*
# Database for cacti
RUN service mysql start & \
		sleep 10s  \
    && echo "create database cacti;" | mysql -u root \
		&& echo "GRANT ALL ON cacti.* TO cactiuser@'%' IDENTIFIED BY 'cactiuser';" | mysql -u rootmysql -u root \
		&& mysql -u root cacti < /opt/cacti/cacti.sql \
		&& tar -cvf /mysql_basic.tar /var/lib/mysql
# Run crontab
RUN (crontab -u root -l; echo "$JOB" ) | crontab -u root -

ADD supervisord.conf /etc/supervisord.conf
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

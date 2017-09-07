#/bin/bash

cat << 'EOF' > Dockerfile
FROM ubuntu
MAINTAINER @Clorets8lack
LABEL OBJECT="MYSQL-Wireshark"

#ENTRYPOINT ["/bin/bash"]
RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get -y install apache2 php libapache2-mod-php apt-utils unzip wget php-mysql
RUN echo "mysql-server mysql-server/root_password password mysql" | debconf-set-selections && \
    echo "mysql-server mysql-server/root_password_again password mysql" | debconf-set-selections && \
    apt-get -y install mysql-server
RUN sed -i -e "s/\(\[mysqld\]\)/\1\ncharacter-set-server = utf8/g" /etc/mysql/my.cnf
RUN sed -i -e "s/\(\[client\]\)/\1\ndefault-character-set = utf8/g" /etc/mysql/my.cnf
RUN sed -i -e "s/\(\[mysqldump\]\)/\1\ndefault-character-set = utf8/g" /etc/mysql/my.cnf
RUN sed -i -e "s/\(\[mysql\]\)/\1\ndefault-character-set = utf8/g" /etc/mysql/my.cnf
RUN service apache2 restart
# setup mysql server
RUN mkdir /home/mysql
RUN chown mysql /home/mysql/
RUN usermod -d /home/mysql/ mysql
RUN /etc/init.d/mysql start

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tshark
WORKDIR /root
RUN wget http://develup-japan.co.jp/wp/downloads/CRUD_for_SampleDB.zip
RUN unzip CRUD_for_SampleDB.zip
RUN mv CRUD_for_SampleDB /var/www/html
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Create startup script
RUN touch /root/init.sh
RUN echo '#!/bin/bash' >> /root/init.sh
RUN echo '/usr/sbin/apache2 &' >> /root/init.sh
RUN echo '/etc/init.d/mysql start'  >> /root/init.sh
RUN echo 'while true ; do' >> /root/init.sh
RUN echo '    /bin/bash' >> /root/init.sh
RUN echo 'done' >> /root/init.sh
RUN chmod 777 /root/init.sh

EOF

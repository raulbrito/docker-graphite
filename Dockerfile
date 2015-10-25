From ubuntu:trusty
MAINTAINER jlachowski "raul.brito@gmail.com"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y -qq update

# node.js using PPA (for statsd)
RUN apt-get -y -qq install screen
RUN apt-get -y -qq install python-software-properties
RUN apt-get -y -qq install software-properties-common
RUN apt-add-repository ppa:chris-lea/node.js
RUN apt-get -y -qq update
RUN apt-get -y -qq install pkg-config make g++
RUN apt-get -y -qq install nodejs

# Install git to get statsd
RUN apt-get -y -qq install git

# System level dependencies for Graphite
RUN apt-get -y -qq install memcached python-dev python-pip sqlite3 libcairo2 \
 libcairo2-dev python-cairo

# Supervisor to run everything
RUN apt-get -y -qq install supervisor

# Get latest pip
RUN pip install --upgrade pip 
 
# Install carbon and graphite deps 
RUN pip install django==1.5.5
RUN pip install gunicorn==18.0
RUN pip install django-tagging==0.3.1
RUN pip install twisted==13.1
RUN pip install whisper==0.9.12
RUN pip install carbon==0.9.12
RUN pip install graphite-web==0.9.12
 
# add storage schema
RUN cd /opt/graphite/conf/ && cp carbon.conf.example carbon.conf 
ADD assets/storage-schemas.conf /opt/graphite/conf/storage-schemas.conf

# configure graphite
RUN mkdir -p /opt/graphite/storage/log/webapp
ADD assets/local_settings.py /opt/graphite/webapp/graphite/local_settings.py
RUN python /opt/graphite/webapp/graphite/manage.py syncdb --noinput

# statsd
RUN git clone git://github.com/etsy/statsd.git /opt/statsd
ADD assets/localConfig.js /opt/statsd/localConfig.js
ADD backends/jsonout.js /opt/statsd/backends/jsonout.js

# supervisord
ADD assets/supervisor-graphite.conf /etc/supervisor/conf.d/graphite.conf

# start script
ADD assets/start-graphite.sh /usr/bin/start-graphite.sh
RUN chmod +x /usr/bin/start-graphite.sh

EXPOSE 5000 8125/udp 2003 2004 7002

CMD ["/usr/bin/start-graphite.sh"]
#CMD sh -c "exec >/dev/tty 2>/dev/tty </dev/tty && /usr/bin/screen -s /bin/bash"

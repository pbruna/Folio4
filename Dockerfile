FROM phusion/passenger-ruby21:0.9.12
MAINTAINER Patricio Bruna <pbruna@itlinux.cl>

RUN rm -f /etc/service/nginx/down
RUN mkdir -p /etc/service/memcached
RUN mkdir -p /home/app/folio4

WORKDIR /home/app/folio4
ADD Gemfile /home/app/folio4/
ADD Gemfile.lock /home/app/folio4/
RUN bundle install

# Aquí para que no moleste al cache
ADD . /home/app/folio4
ADD config/folio-nginx.conf /etc/nginx/sites-enabled/folio-nginx.conf
ADD scripts/delayed_job.sh /etc/service/delayed_job/run

ENV RAILS_ENV production

RUN rake db:migrate
RUN rake db:seed
RUN rake assets:precompile
#RUN rake assets:sync
RUN rake tmp:create
RUN rake tmp:clear

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
CMD ["/sbin/my_init"]

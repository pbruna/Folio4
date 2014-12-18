# TODO Hacer que delayed_job suba como servicio

FROM phusion/passenger-ruby21:0.9.12
MAINTAINER Patricio Bruna <pbruna@itlinux.cl>

RUN rm -f /etc/service/nginx/down
RUN mkdir -p /home/app/folio4

WORKDIR /home/app/folio4
ADD Gemfile /home/app/folio4/
ADD Gemfile.lock /home/app/folio4/
RUN bundle install

ADD config/folio-nginx.conf /etc/nginx/sites-enabled/folio-nginx.conf
ADD config/folio-nginx-env.conf /etc/nginx/main.d/folio-nginx-env.conf
ADD scripts/delayed_job.sh /etc/service/delayed_job/run
ADD pbruna-ssh-key.pub /tmp/your_key
RUN cat /tmp/your_key >> /root/.ssh/authorized_keys && rm -f /tmp/your_key
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN touch /var/log/delayed_job.log
RUN chown 9999:9999 /var/log/delayed_job.log

# Aquí para que no moleste al cache
ADD . /home/app/folio4

ENV RAILS_ENV production

RUN rake db:migrate
RUN rake db:seed
RUN rake assets:precompile
RUN rake assets:sync
RUN rake tmp:create
RUN rake tmp:clear
RUN chown 9999:9999 -R /home/app/folio4

CMD ["/sbin/my_init"]

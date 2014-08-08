FROM rails
MAINTAINER Patricio Bruna <pbruna@itlinux.cl>

ENV RAILS_ENV production

RUN rake db:migrate
RUN rake db:seed
RUN rake assets:precompile
RUN rake tmp:clear
RUN rake tmp:create

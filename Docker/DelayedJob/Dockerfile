FROM pbruna/centos-rails:4.0.2
MAINTAINER Patricio Bruna <pbruna@itlinux.cl>

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ADD Gemfile /usr/src/app/
ADD Gemfile.lock /usr/src/app/
RUN bundle install

ADD . /usr/src/app

ENV RAILS_ENV production

RUN rake tmp:create
RUN rake tmp:clear

CMD rake jobs:work
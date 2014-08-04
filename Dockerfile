FROM centos
MAINTAINER Patricio Bruna <pbruna@itlinux.cl>

RUN rpm -Uvh http://epel.gtdinternet.com/beta/7/x86_64/epel-release-7-0.2.noarch.rpm
RUN yum install ruby mysql-devel sqlite-devel libxml2-devel nodejs json-c-devel.x86_64 rubygem-bundler.noarch git ruby-devel gcc make tar gzip bzip2 autoconf automake diffstat elfutils gcc gcc-c++ gcc-gfortran gettext git intltool libtool make patch patchutils rcs -y

RUN mkdir -p /home/folio/app

ADD ./RailsApp /home/folio/app

WORKDIR /home/folio/app

RUN bundle install --binstubs --deployment
RUN rake db:migrate
RUN rake assets:precompile

CMD rails s
EXPOSE 3000

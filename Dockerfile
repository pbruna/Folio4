FROM pbruna/centos-rails:4.0.0
MAINTAINER Patricio Bruna <pbruna@itlinux.cl>

RUN mkdir -p /home/folio/RailsApp

ADD RailsApp/Gemfile /home/folio/RailsApp/Gemfile
ADD RailsApp/Gemfile.lock /home/folio/RailsApp/Gemfile.lock

WORKDIR /home/folio/RailsApp
RUN bundle install

ADD RailsApp /home/folio/

RUN RAILS_ENV=production rake db:migrate
RUN RAILS_ENV=production rake db:seed
RUN RAILS_ENV=production rake assets:precompile

CMD RAILS_ENV=production bundle exec rails s
EXPOSE 3000

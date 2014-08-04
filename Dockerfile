FROM pbruna/centos-rails:4.0.0
MAINTAINER Patricio Bruna <pbruna@itlinux.cl>

RUN mkdir -p /home/folio/app
ADD RailsApp/Gemfile /home/folio/app/
ADD RailsApp/Gemfile.lock /home/folio/app/
WORKDIR /home/folio/app
RUN bundle install

ADD ./RailsApp /home/folio/app
RUN bundle install
RUN RAILS_ENV=production rake db:migrate
RUN RAILS_ENV=production rake db:seed
RUN RAILS_ENV=production rake assets:precompile

CMD RAILS_ENV=production bundle exec rails s
EXPOSE 3000

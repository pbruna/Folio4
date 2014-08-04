FROM pbruna/centos-rails:4.0.0
MAINTAINER Patricio Bruna <pbruna@itlinux.cl>

mkdir -p /home/folio
WORKDIR /home/folio
RUN git clone https://github.com/pbruna/Folio4.git

ADD RailsApp/Gemfile /home/folio/Folio4/RailsApp/Gemfile
ADD RailsApp/Gemfile.lock /home/folio/Folio4/RailsApp/Gemfile.lock

WORKDIR /home/folio/Folio4/RailsApp
RUN bundle install

RUN RAILS_ENV=production rake db:migrate
RUN RAILS_ENV=production rake db:seed
RUN RAILS_ENV=production rake assets:precompile

CMD RAILS_ENV=production bundle exec rails s
EXPOSE 3000

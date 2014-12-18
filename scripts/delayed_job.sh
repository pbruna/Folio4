#!/bin/sh

exec su app -c "cd /home/app/folio4 && rake jobs:work RAILS_ENV=production >>/var/log/delayed_job.log 2>&1"
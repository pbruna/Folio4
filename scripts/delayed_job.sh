### In delayed_job.sh (make sure this file is chmod +x):
#!/bin/sh
# `chpst` is part of running. `chpst -u app` runs the given command
# as the user `app`. If you omit this, the command will be run as root.
cd /home/app/folio4
exec chpst -u app rake jobs:work RAILS_ENV=production >>/var/log/delayed_job.log 2>&1
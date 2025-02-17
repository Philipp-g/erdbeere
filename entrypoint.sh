#!/usr/bin/env bash
cd /usr/src/app
if ! [ -f completed_initial_run ]
then
  echo 'Initialising mampf' &> >(tee -a /usr/src/app/log/initialisation.log)
  echo running: bundle exec rails assets:precompile &> >(tee -a /usr/src/app/log/initialisation.log)
  bundle exec rails assets:precompile &> >(tee -a /usr/src/app/log/initialisation.log)
  echo running: bundle exec rails db:schema:load &> >(tee -a /usr/src/app/log/initialisation.log)
  bundle exec rails db:schema:load &> >(tee -a /usr/src/app/log/initialisation.log)
  echo running: bundle exec rails db:seed &> >(tee -a /usr/src/app/log/initialisation.log)
  bundle exec rails db:seed &> >(tee -a /usr/src/app/log/initialisation.log)
  echo 'finished initialisation' &> >(tee -a /usr/src/app/log/initialisation.log)
  touch completed_initial_run
fi
rm -f tmp/pids/server.pid
echo "running mampf"
exec bundle exec rails s -p 3000 -b '0.0.0.0' &> >(tee -a /usr/src/app/log/runtime.log)

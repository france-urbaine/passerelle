#!/bin/bash -l

bundle exec rails assets:precompile

if [[ $? -ne 0 ]]
then
  exit 1
fi

if [ "$INSTANCE_NUMBER" == "0" ] && [ "$POSTGRESQL_MAINTENANCE" != "true" ]
then
  bundle exec rails db:migrate
fi

#!/bin/bash -l

if [ "$INSTANCE_NUMBER" == "0" ] && \
   [ "$EXECUTE_CRON" == "true" ] && \
   [ "$POSTGRESQL_MAINTENANCE" != "true" ]
then
  PATH="/home/bas/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
  cd $APP_HOME

  bundle exec rails cron:daily
fi

#! /usr/bin/env bash

if [ $INSTANCE_NUMBER -ne 0 ]; then
    echo "Don't run cron on instance $INSTANCE_NUMBER";
    exit 0;
fi

source /home/bas/applicationrc

eval "$(/home/bas/.rbenv/bin/rbenv init -)"

cd $APP_HOME
bundle exec rake export:userdata

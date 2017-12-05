#! /usr/bin/env bash
source /home/bas/applicationrc

eval "$(/home/bas/.rbenv/bin/rbenv init -)"

cd $APP_HOME
bundle exec rake export:userdata

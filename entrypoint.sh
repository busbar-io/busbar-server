#!/usr/bin/env bash

case "$1" in
  webserver)
    exec bundle exec puma -e ${RAILS_ENV} -p ${PORT}
    ;;
  worker)
    exec bundle exec sidekiq -e ${RAILS_ENV}
    ;;
  *)
    # The command is something like bash, not a busbar subcommand.
    exec "$@"
    ;;
esac

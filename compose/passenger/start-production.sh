#!/bin/sh

RAILS_ENV=production rails db:migrate
export SECRET_KEY_BASE=$(rails secret)
RAILS_ENV=production puma
RAILS_ENV=production rails assets:precompile

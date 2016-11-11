#!/bin/bash
set -e
cmd="$@"

export rvm_bin_path=/usr/local/rvm/bin
export GEM_HOME=/usr/local/rvm/gems/ruby-2.3.1
export IRBRC=/usr/local/rvm/rubies/ruby-2.3.1/.irbrc
export MY_RUBY_HOME=/usr/local/rvm/rubies/ruby-2.3.1
export rvm_path=/usr/local/rvm
export rvm_prefix=/usr/local
export PATH=/usr/local/rvm/gems/ruby-2.3.1/bin:/usr/local/rvm/gems/ruby-2.3.1@global/bin:/usr/local/rvm/rubies/ruby-2.3.1/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/rvm/bin
export GEM_PATH=/usr/local/rvm/gems/ruby-2.3.1:/usr/local/rvm/gems/ruby-2.3.1@global
export RUBY_VERSION=ruby-2.3.1

# the official postgres image uses 'postgres' as default user if not set explictly.
if [ -z "$POSTGRES_USER" ]; then
    export POSTGRES_USER=postgres
fi

function postgres_ready(){
/usr/bin/env ruby << END
require "pg"
begin
  con = PG.connect  :host => "db", :user => "$POSTGRES_USER", :connect_timeout => 1
rescue
  exit -1
ensure
  con.close if con
end
exit 0
END
}


until postgres_ready; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

>&2 echo "Postgres is up - continuing..."

exec $cmd

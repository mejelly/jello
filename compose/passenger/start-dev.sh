#!/bin/bash

export rvm_bin_path=/usr/local/rvm/bin
export GEM_HOME=/usr/local/rvm/gems/ruby-2.3.1
export IRBRC=/usr/local/rvm/rubies/ruby-2.3.1/.irbrc
export MY_RUBY_HOME=/usr/local/rvm/rubies/ruby-2.3.1
export rvm_path=/usr/local/rvm
export rvm_prefix=/usr/local
export PATH=/usr/local/rvm/gems/ruby-2.3.1/bin:/usr/local/rvm/gems/ruby-2.3.1@global/bin:/usr/local/rvm/rubies/ruby-2.3.1/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/rvm/bin
export GEM_PATH=/usr/local/rvm/gems/ruby-2.3.1:/usr/local/rvm/gems/ruby-2.3.1@global
export RUBY_VERSION=ruby-2.3.1

/usr/local/rvm/gems/ruby-2.3.1/bin/rails db:create db:migrate db:seed
/usr/local/rvm/gems/ruby-2.3.1/bin/rails s -p 3000 -b 0.0.0.0

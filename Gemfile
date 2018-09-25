source "https://rubygems.org"

ruby "~> 2.5.1"

gem "rails", "~> 5.2.1.rc1"

gem "activerecord-session_store"
gem "auto_increment"
gem "active_model_serializers"
gem "bootstrap-datepicker-rails"
gem "bootstrap-multiselect-rails"
gem "bootstrap-sass", "~> 3.3.6"
gem "bootstrap3-datetimepicker-rails"
gem "business_time"
gem "clockwork", require: false
gem "cocoon"
gem "coffee-rails"
gem "countries"
gem "country_select"
gem "daemons"
gem "delayed_job_active_record"
gem "devise"
gem "devise-async"
gem "dotenv-rails"
gem "faker"
gem "flutie"
gem "font-awesome-rails"
gem "jquery-rails"
gem "haml"
gem "pg"
gem "momentjs-rails"
gem "nokogiri", ">= 1.8.3"
gem "notifications-ruby-client", "= 1.1.2"
gem "paperclip", ">= 5.2.0"
gem "paperclip-azure",
    git: "https://github.com/mcagov/paperclip-azure"
gem "pg_backup"
gem "pg_search"
gem "prawn"
gem "prawn-print"
gem "prawn-table"
gem "protokoll"
gem "puma"
gem "rack-cors"
gem "remotipart"
gem "rake", "~> 12.3.0"
gem "sass-rails", "~> 5.0"
gem "select2-rails"
gem "simple_form"
gem "sprockets", ">= 3.7.2"
gem "sprockets-es6"
gem "title"
gem "transitions", require: ["transitions", "active_model/transitions"]
gem "travis"
gem "trix", git: "https://github.com/bcoia/trix.git"
gem "uglifier"
gem "validates_email_format_of"
gem "waves-utilities",
    git: "https://github.com/mcagov/waves-utilities.git"
gem "will_paginate-bootstrap"

group :development do
  gem "guard-rspec", require: false
  gem "rails-erd"
  gem "web-console"
end

group :development, :test do
  gem "awesome_print"
  gem "bullet"
  gem "bundler-audit", ">= 0.5.0", require: false
  gem "capistrano", "~> 3.7"
  gem "capistrano-rails", "~> 1.2"
  gem "capistrano-passenger"
  gem "capistrano-delayed_job", require: false
  gem "factory_bot_rails"
  gem "parallel_tests"
  gem "pry-byebug"
  gem "pry-rails"
  gem "rspec-rails"
  gem "rubocop", "= 0.43.0",
      branch: "release/0.43.0",
      require: false,
      git: "https://github.com/mcagov/rubocop.git"
end

group :test do
  gem "brakeman"
  gem "capybara", "2.13.0"
  gem "capybara-webkit", "1.14.0"
  gem "email_spec"
  gem "database_cleaner"
  gem "formulaic"
  gem "launchy"
  gem "pdf-reader"
  gem "rack_session_access"
  gem "rails-controller-testing"
  gem "shoulda-matchers"
  gem "simplecov", require: false
  gem "timecop"
  gem "webmock"
end

group :staging, :production do
  gem "rack-timeout"
end

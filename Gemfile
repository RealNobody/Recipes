source 'https://rubygems.org'

gem 'rails', ">= 4.0"
gem "bcrypt-ruby"
gem 'devise'                # Login gem
gem 'kaminari'              # Paging Gem
gem 'thin'

# bootstrap
gem 'sass-rails', '>= 3.2' # sass-rails needs to be higher than 3.2
# gem 'bootstrap-sass', '~> 3.0.2.0'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

group :development do
  gem 'annotate'
  gem "better_errors"       # a prettier error page.
  gem "binding_of_caller"   # used by better_errors for a better view.
end

group :development, :test do
  gem "rspec-rails"
  gem "mysql2"
  gem "guard-rspec"
  gem "guard-spork"
  gem "spork"

  gem 'listen'
  gem 'rb-inotify', :require => false
  gem 'rb-fsevent', :require => false
  # gem "autotest-fsevent", require: false
  gem 'rb-fchange', :require => false
end

# Test gems on Macintosh OS X
group :test do
  gem "database_cleaner"
  gem 'simplecov', :require => false
  gem 'capybara'
  gem "selenium-webdriver"
  gem "site_prism"                    # page object model - https://github.com/natritmeyer/site_prism
  # gem 'rb-fsevent', '0.9.1', require: false
  gem 'growl'
  gem 'factory_girl_rails'
  gem 'faker'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'

group :production do
  gem 'pg'
end

group :test do
  gem 'galaxy-test_support', '~> 0.0.12', :path => '../../Deem/code/galaxy-test_support'
  #gem 'galaxy-test_support', '~> 0.0.12', :git => "git@github.com:demandchain/galaxy-test_support.git"
end
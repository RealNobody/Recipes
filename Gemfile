source 'https://rubygems.org'

gem 'rails'
gem 'bootstrap-sass'
gem "bcrypt-ruby"
gem 'devise'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

group :development do
  gem 'annotate'
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
  gem 'capybara'
  # gem 'rb-fsevent', '0.9.1', require: false
  gem 'growl'
  gem 'factory_girl_rails'
  gem 'faker'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
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
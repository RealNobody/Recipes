source 'https://rubygems.org'

gem 'rails', ">= 4.0"
gem "bcrypt-ruby"
gem 'devise' # Login gem
gem 'kaminari' # Paging Gem
gem 'thin'
gem "haml-rails"

# bootstrap
gem 'sass-rails', '>= 3.2' # sass-rails needs to be higher than 3.2
# gem 'bootstrap-sass', '~> 3.0.2.0'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

group :development do
  gem 'annotate'
  gem "better_errors" # a prettier error page.
  gem "binding_of_caller" # used by better_errors for a better view.
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
  gem "site_prism" # page object model - https://github.com/natritmeyer/site_prism
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

gem 'seedling', '~> 0.0.7', :git => "git@github.com:RealNobody/seedling.git"
# gem 'seedling', '~> 0.0.7', :path => '../seedling'

group :test do
  # gem 'cornucopia', '~> 0.1.4', :git => "git@github.com:RealNobody/cornucopia.git"
  gem 'cornucopia', '~> 0.1.4', :path => '../cornucopia'

  # gem 'pseudo_cleaner', '~> 0.0.15', :git => "git@github.com:RealNobody/pseudo_cleaner.git"
  gem 'pseudo_cleaner', '~> 0.0.15', :path => '../pseudo_cleaner'
  gem "colorize"
end
source "https://rubygems.org"
ruby "1.9.3"
 
gem "sinatra"
gem "activerecord"
gem "sinatra-activerecord"
gem 'sinatra_more'
gem 'sinatra-param'

gem 'thin'

group :production do
  gem 'pg'
end

group :development do
  gem "mysql"
  gem "mysql2"
  gem 'pry'
  gem 'guard'
  gem 'guard-rspec'
end

group :test do
  gem 'sqlite3'
  gem 'rspec'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'factory_girl'
  gem 'faker'
  gem 'rack-test'
  gem "codeclimate-test-reporter", require: nil
end

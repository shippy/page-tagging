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
end

group :test do
  gem 'sqlite3'
  gem 'rspec'
  gem 'rack-test'
  gem "codeclimate-test-reporter", require: nil
end

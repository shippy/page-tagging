require 'sinatra'
require 'yaml'
require 'sinatra/activerecord'
require 'csv'

# model of a Node
require './node.rb'
 
DB_CONFIG = YAML::load(File.open('database.yml'))['development']
set :database, "mysql://#{DB_CONFIG['username']}:#{DB_CONFIG['password']}@#{DB_CONFIG['host']}:#{DB_CONFIG['port']}/#{DB_CONFIG['database']}"

## Application initialization - import the CSV file with the URLs
get '/import' do
	erb :import
end

post '/import' do
	# need to skip validations
end

## Application body - tagging the pages
# Main page - display the website and the tagging mechanism
get '/' do
	# Initialize application
	redirect to('/import') unless Node.exists?

	node = Node.where(tag: nil).first
	@url = node.url
	@rank = node.rank

	erb :classify
end

# Submission handling
post '/submit' do
	node = Node.where(url: params[:url]).first
	node.update(params)

	# implement actual AJAX response here
	if node.changed?
		"Success"
	else
		"Failure"
	end
end
# To read:
# - http://stackoverflow.com/questions/15377367/using-sinatra-and-jquery-without-redirecting-on-post
# - http://ididitmyway.herokuapp.com/past/2011/2/27/ajax_in_sinatra/
# - http://www.sitepoint.com/guide-ruby-csv-library-part/
# - http://samuelstern.wordpress.com/2012/11/28/making-a-simple-database-driven-website-with-sinatra-and-heroku/
# - http://www.sinatrarb.com/intro.html

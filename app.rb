require 'sinatra'
require 'yaml'
require 'sinatra/activerecord'
require 'csv'
require 'sinatra/twitter-bootstrap'
require 'sinatra_more/markup_plugin'

# model of a Node
require './node.rb'
 
DB_CONFIG = YAML::load(File.open('database.yml'))['development']
set :database, "mysql://#{DB_CONFIG['username']}:#{DB_CONFIG['password']}@#{DB_CONFIG['host']}:#{DB_CONFIG['port']}/#{DB_CONFIG['database']}"

class PageTagger < Sinatra::Base
	register SinatraMore::MarkupPlugin
	## Application initialization - import the CSV file with the URLs
	get '/import' do
		erb :import
		# TODO: Create the file upload form
	end
	
	post '/upload' do
		file = File.open(params[:file], 'r+')
		'Success'
		# tempfile.each_line do |line|
			# sanitize the URL
			# save URL and rank to DB; need to skip validations
			# rank += 1
			# print(rank, line)
		# end
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
		# TODO: Create the tagging view
	end
	
	# Submission handling
	post '/submit' do
		node = Node.where(url: params[:url]).first
		node.update(params)
	
		# TODO: implement actual AJAX response here
		if node.changed?
			"Success"
		else
			"Failure"
		end
	end
end

PageTagger.run!

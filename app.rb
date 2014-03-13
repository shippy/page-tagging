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
		unless params[:file] &&
			(tmpfile = params[:file][:tempfile]) &&
			(name = params[:file][:filename])
			@error = "No file selected"
			return erb(:upload)
		end

		rank = 0
		while blk = tmpfile.read(65536)
			lines = blk.split("\n")
			lines.each do |line|
				node = Node.create
				node.url = line
				node.rank = rank
				node.save(validate: false)
			end
			redirect to('/')
		end
	end
	
	## Application body - tagging the pages
	# Main page - display the website and the tagging mechanism
	get '/' do
		# Initialize application
		redirect to('/import') unless Node.exists?
	
		node = Node.where("tag is NULL").first
		@url = node[:url]
		@rank = node[:rank]
	
		erb :classify
	end
	
	# Submission handling
	post '/submit' do
		node = Node.where(url: params[:url]).first
		node.update_attributes(params)
	
		# TODO: implement actual AJAX response here
		if node.changed?
			"Success"
		else
			"Failure"
		end
	end
end

PageTagger.run!

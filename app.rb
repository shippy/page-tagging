require 'sinatra'
require 'yaml'
require 'sinatra/activerecord'
require 'csv'
require 'sinatra/twitter-bootstrap'
require 'sinatra_more/markup_plugin'

# model of a Node
require './config/environments'
require './node.rb'

#DB_CONFIG = YAML::load(File.open('config/database.yml'))['development']
#set :database, "mysql://#{DB_CONFIG['username']}:#{DB_CONFIG['password']}@#{DB_CONFIG['host']}:#{DB_CONFIG['port']}/#{DB_CONFIG['database']}"
class PageTagger < Sinatra::Base
	## Initial setup
	enable :sessions
	set :logging, :true

	register SinatraMore::MarkupPlugin
	after { ActiveRecord::Base.connection.close } # Fixes a timeout bug; see #6
	set :protection, :except => :frame_options

	## Helper methods
	helpers do
		def nextNode
			Node.where("tag is NULL").first
		end
	end

	## Application initialization - import text file with the URLs
	get '/import' do
		erb :import
	end
	
	post '/upload' do
		unless params[:file] &&
			(tmpfile = params[:file][:tempfile]) &&
			(name = params[:file][:filename])
			@error = "No file selected"
			return erb(:import)
		end

		rank = 0
		while blk = tmpfile.read(65536)
			lines = blk.split("\n")
			lines.each do |line|
				rank += 1
				node = Node.create
				node.url = line
				node.rank = rank
				node.save(validate: false)
				# FIXME: This could possibly fail if a link is split by 65536th bit
			end
			redirect to('/')
		end
	end

	## Application body - tagging the pages
	# Main page - display the website and the tagging mechanism
	get '/' do
		# Initialize application
		redirect to('/import') unless Node.exists?
	
		node = nextNode
		@url = node[:url]
		@rank = node[:rank]
		@tagger = session[:tagger]
	
		erb :classify
	end
	
	# Submission handling
	post '/submit' do
		session[:tagger] = params[:tagger]

		node = Node.where(url: params[:url]).first
		# TODO: Make this asynchronous
		if node.update_attributes(params)
			redirect to('/')
			"Success"
		else
			"Failure"
		end
	end

	get '/next-url' do
		node = nextNode()
		return node[:url]
	end
end

PageTagger.run!

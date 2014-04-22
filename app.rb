require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra_more/markup_plugin'
require 'sinatra/param'
require 'uri'

# model of a Node
require './config/environments'
require './node.rb'

#DB_CONFIG = YAML::load(File.open('config/database.yml'))['development']
#set :database, "mysql://#{DB_CONFIG['username']}:#{DB_CONFIG['password']}@#{DB_CONFIG['host']}:#{DB_CONFIG['port']}/#{DB_CONFIG['database']}"
class PageTagger < Sinatra::Base
	## Initial setup
	enable :sessions
	set :logging, :true

	helpers Sinatra::Param
	register SinatraMore::MarkupPlugin
	after { ActiveRecord::Base.connection.close } # Fixes a timeout bug; see #6
	set :protection, :except => :frame_options

	## Helper methods
	helpers do
		# Gets next untagged node
		def nextNode
			Node.where("tag is NULL").first(10).sample
		end
		
		def nodesRemainingCount
		  Node.where("tag is NULL").count
	  end
	  
    def allNodesCount
      Node.count
    end

		# Takes a block of text, splits it by newlines, and imports all entries that are valid URLs
		def import_urls(block)
			rank = 0
			lines = block.split(/[\r]?\n/)
			lines.each do |l|
				if l =~ /^#{URI::regexp}$/
					rank += 1
					node = Node.create({url: l, rank: rank})
					node.save(validate: false)
				end
			end
			return true
		end

		# Tagging options
		# TODO: rename to tags
		# TODO: load from a config file
		def options
			Hash["major", "Major media",
				"minor", "Minor media",
				"informational", "Informational",
				"college", "College media",
				"blog", "Blog / personal",
				"review", "Other"]
		end
	end

	## Application initialization - import text file with the URLs
	# Import form
	get '/import' do
		erb :import
	end
	
	# Import management - in pure text
	post '/import-text' do
		unless import_urls(params[:text])
			halt 500
		else
			redirect to('/'), 200
		end
	end

	# Import management - as a file
	post '/import-file' do
		# Check that file has been uploaded
		unless params[:file] &&
			(tmpfile = params[:file][:tempfile]) &&
			(name = params[:file][:filename])
			@error = "No file selected"
			return erb(:import)
		end

		# Read the entire uploaded file into variable
		block = ""
		while blk = tmpfile.read(65536)
			block << blk
		end

		# Import into database
		unless import_urls(block)
			halt 500
		else
			redirect to('/'), 200
		end
	end

	# Export all as json
	#get '/export/?:tag?' do
	get '/export' do
	  # TODO: specific tag
		attachment "tagged-urls.json"
		Node.all.to_json
	end

	## Application body - tagging the pages
	# Main page - display the website and the tagging mechanism
	get '/' do
		# Do records exist?
		redirect to('/import') unless Node.exists?
	
		node = nextNode
		@url = node[:url]
		@rank = node[:rank]
		@tagger = session[:tagger]
		
		@remaining = nodesRemainingCount
		@nodesCount = allNodesCount
	
		erb :classify
	end

	get '/flagged' do
		# Do flagged records exist?
		halt(500) unless Node.exists?
	
		node = Node.where(tag: 'review').first
		@url = node[:url]
		@rank = node[:rank]
		@tagger = session[:tagger]
	
		erb :classify
	end
	
	# Submission handling
	post '/submit' do
		# Parameter contracts
		param :tag, String, in: options.keys.to_a, transform: :downcase, required: true
		param :tagger, String, required: true
		param :url, String, required: true

		# Save name into session so it doesn't have to be entered again
		session[:tagger] = params[:tagger]

		# Find 
		node = Node.where(url: params[:url]).first || halt(400)
		# TODO: Make this asynchronous
		if node.update_attributes(params)
			redirect back
		else
			halt 400
		end
	end

	get '/next-url' do
		node = nextNode()
		return node[:url]
	end
end

PageTagger.run!

require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra_more/markup_plugin'
require 'sinatra/param'
require 'uri'

require './config/environments'
require './node.rb'

class PageTagger < Sinatra::Base
	## Initial setup
	enable :sessions
	set :logging, :true

	helpers Sinatra::Param
	register SinatraMore::MarkupPlugin
	after { ActiveRecord::Base.connection.close } # Fixes a timeout bug; see #6
  # set :protection, :except => :frame_options

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
				"other", "Other",
				"review", "Flag"]
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
	
	get '/finished' do
	  if nextNode.nil?
	    "All pages have been tagged! Do you want to <a href='/import'>import more</a>, or perhaps retag the <a href='/tag/review/'>previously flagged ones?</a>"
    else
      redirect to('/')
    end
  end

	# Export all as json
	get '/export/?:tag?' do |tag|
	  if tag
		  attachment tag + ".json"
		  Node.where(tag: tag).all.to_json
	  else
	    attachment "all-urls.json"
  		Node.all.to_json
    end
	end
	
	get '/export-except/:tag' do |tag|
	  attachment "urls-except-" + tag + ".json"
	  Node.where('tag != ?', tag).all.to_json
  end

	## Application body - tagging the pages
	# Main page - display the website and the tagging mechanism
	get '/' do
		# Do records to be tagged exist?
		redirect to('/import') unless Node.exists?
	  node = nextNode
	  redirect to('/finished') if node.nil?
	  
  	@url = node[:url]
  	@rank = node[:rank]	  
		@tagger = session[:tagger]
		
		@remaining = nodesRemainingCount
		@nodesCount = allNodesCount
	
		erb :classify
	end

	get '/tag/:tag' do |tag|
		# Do flagged records exist?
		halt(500) unless Node.where(tag: tag).exists?
	
		node = Node.where(tag: tag).sample
		@url = node[:url]
		@rank = node[:rank]
		@tagger = session[:tagger]
		
		@nodesCount = Node.where(tag: tag).count
		@remaining = 0
		
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
		node = Node.where(url: params[:url]) || halt(400)
		# TODO: Make this asynchronous
		if node.update_all(params)
		  puts "Updating with " + params.to_s
			redirect back
		else
		  puts "Failing with " + params.to_s
			halt 400
		end
	end

	get '/next-url' do
		node = nextNode()
		return node[:url]
	end
	
	get '/stats' do
	  taggers = Node.all.select(:tagger)
	  count = Hash.new(0)
	  taggers.each do |t|
	    next if t.tagger == nil
	    next if t.tagger == ""
	    count[t.tagger.downcase.capitalize] += 1
	  end
	  @count = count.sort_by{|k, v| v}.reverse
	  
	  erb :stats
  end
  
  get '/list' do
    @nodes = Hash.new
    tag = nil
    
    Node.order(:tag).each do |n|
      unless n.tag == tag
        tag = n.tag
      end
      @nodes[tag] ||= Array.new
      @nodes[tag] << n.url
    end
    
    erb :list
  end
end

# PageTagger.run!

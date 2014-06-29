class PageTagger < Sinatra::Base
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

  get '/retag/:tag' do |tag|
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
  
  get '/retag' do
    @tags = Node.uniq.pluck(:tag)
    @tags.delete_if { |e| e.nil? }.to_s
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
  
  get '/finished' do
    if Node.exists? and nextNode.nil?
      "All pages have been tagged! Do you want to <a href='/import'>import more</a>," +
      " or perhaps retag the <a href='/retag/review/'>previously flagged ones?</a>"
    else
      redirect to('/')
    end
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
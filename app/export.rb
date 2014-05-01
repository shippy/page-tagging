class PageTagger < Sinatra::Base
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
end
class PageTagger < Sinatra::Base
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
end
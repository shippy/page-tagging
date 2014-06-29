class PageTagger < Sinatra::Base
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
end
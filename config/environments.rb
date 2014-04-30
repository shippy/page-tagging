configure :production, :development do
	db = URI.parse(ENV['DATABASE_URL'] || 'mysql://root@localhost/page_tagging')
	 
	ActiveRecord::Base.establish_connection(
		:adapter => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
		:host => db.host,
		:username => db.user,
		:password => db.password,
		:database => db.path[1..-1],
		:encoding => 'utf8'
	)
end

configure :test do
  db = URI.parse('mysql://root@localhost/page_tagging_test')
  ActiveRecord::Base.establish_connection(
		:adapter => db.scheme,
		:host => db.host,
		:username => db.user,
		:password => db.password,
		:database => db.path[1..-1],
		:encoding => 'utf8'
	)
end
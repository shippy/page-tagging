require 'sinatra'

get '/' do
	'Hello world!'
	# render the name input and content categorization in the top
	# and iframe of the page in the bottom
end

get '/label/*' do |label|
	# check if name has been put in?
	if params[:label] in %w{progressive neutral conservative review}
		# save to db
	else
		"Incorrect label"
	end
end

# If there's no database, load up csv file with google results
# If there is a database:
# 	get '/' is classifier which takes the next unlabelled page
# 		and displays the Progressive-Neutral-Conservative /
# 		Unrelated rating, as well as containing a possible
# 		review flag and a trigger for name
#	post '/label' is the AJAX-triggered submission page that
#		checks if all requirements are satisfied, and adds
#		the result to the databse
# TODO:
# - figure out how to set up a database with sinatra
# - figure out how to do a csv > db
# - figure out the templating in Sinatra
# - figure out the AJAX
# - figure out deployment
#
# To read:
# - http://stackoverflow.com/questions/15377367/using-sinatra-and-jquery-without-redirecting-on-post
# - http://ididitmyway.herokuapp.com/past/2011/2/27/ajax_in_sinatra/
# - http://www.sitepoint.com/guide-ruby-csv-library-part/
# - http://samuelstern.wordpress.com/2012/11/28/making-a-simple-database-driven-website-with-sinatra-and-heroku/
# - http://www.sinatrarb.com/intro.html

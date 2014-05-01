require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra_more/markup_plugin'
require 'sinatra/param'
require 'uri'

require './config/environments'

class PageTagger < Sinatra::Base
	enable :sessions
	set :logging, :true

	helpers Sinatra::Param
	register SinatraMore::MarkupPlugin
	after { ActiveRecord::Base.connection.close } # Fixes a timeout bug; see #6
end

# Model & helpers
require_relative 'node'
require_relative 'app/helpers'
PageTagger.helpers Sinatra::NodeHelpers
PageTagger.helpers Sinatra::ImportHelpers
PageTagger.helpers Sinatra::Settings

# Controllers
require_relative 'app/tagging'
require_relative 'app/import'
require_relative 'app/export'
require_relative 'app/stats'
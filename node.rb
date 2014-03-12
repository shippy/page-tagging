class Node < ActiveRecord::Base
	attr_reader :url, :rank
	attr_writer :tag, :tagger

	validates :tagger, :url, :tag, presence: true
	validates :tag, presence: true, inclusion: { in: %w{progressive neutral conservative review} }
end

class Node < ActiveRecord::Base
	#attr_protected :url, :rank
	#attr_accessible :tag, :tagger

	#validates :tagger, :url, :tag, presence: true
	#validates :tag, presence: true, inclusion: { in: %w{progressive neutral conservative review} }
end

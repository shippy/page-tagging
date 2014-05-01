module Sinatra
  module NodeHelpers
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
  end
  module ImportHelpers
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
  end

  module Settings
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
end
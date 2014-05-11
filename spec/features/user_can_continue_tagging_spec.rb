require 'spec_helper'

shared_examples "User can tag a page and see another", js: true do |page|
  before do
    3.times do
      node = Node.new(url: Faker::Internet.url)
      node.save
    end
    visit page
  end
  after { Node.delete_all }
  
  it "displays new when user submits a tag" do
    old_url = find("iframe")['src']
    find(:id, 'review-radio').click
    find("iframe")['src'].should_not == old_url
  end
  
  
end

describe '/' do
  it_behaves_like "User can tag a page and see another", '/'
end

describe '/retag/:tag' do
  before do
    3.times do
      node = Node.new(url: Faker::Internet.url, tag: 'review')
      node.save
    end
  end
  
  it_behaves_like "User can tag a page and see another", "/retag/review"
end
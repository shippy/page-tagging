require 'spec_helper'
require 'json'

before(:all) do
  10.times do
    node = Node.create(url: 'localhost', tag: %w{other review}.sample)
    node.save
  end
end

after(:all) { Node.delete_all }

shared_examples 'an export file' do
  describe "is application/json" do
    subject { last_response.header["Content-Type"] }
    it { should include "application/json" }
  end
end

describe "/export" do
  before(:each) { get '/export' }
  it_behaves_like "an export file"
  it "contains all nodes" do
    last_response.body.should == Node.all.to_json
  end
end

describe "/export/:tag" do
  before(:all) do
    get '/export/review'
    @json = JSON.parse(last_response.body)
  end
  
  it_behaves_like "an export file"
  it "has no nodes with a different tag" do
    @json.each do |node|
      node.tag.should == 'review'
    end
  end
  
  it "contains all nodes with a given tag" do
    @json.should == Node.where(tag: 'review').to_a
  end
end

describe "/export-except/:tag" do
  before(:each) do
    get '/export-except/review'
    @json = JSON.parse(last_response.body)
  end
  it_behaves_like "an export file"
  it "contains no nodes with a given tag" do
    @json.each do |n|
      n.tag.should != 'review'
    end
  end
  it "contains all nodes without a given tag" do
    @json.should == Node.where("tag != ?", 'review').to_a
  end
  it "contains all nodes if tag non-existent" do
    get '/export-except/nonexistent'
    JSON.parse(last_response.body).should == Node.all.to_a
  end
end
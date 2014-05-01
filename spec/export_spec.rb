require 'spec_helper'

shared_examples 'an export file' do
  describe "is application/json" do
    subject { last_response.header["Content-Type"] }
    it { should include "application/json" }
  end
  
end

describe "/export" do
  before(:each) { get '/export' }
  it_behaves_like "an export file"
  it "contains all nodes"
end

describe "/export/:tag" do
  before(:each) { get '/export/review' }
  it_behaves_like "an export file"
  it "only contains nodes with a given tag"
  it "contains all nodes with a given tag"
  it "contains nothing if tag non-existent"
end

describe "/export-except/:tag" do
  before(:each) { get '/export-except/review' }
  it_behaves_like "an export file"
  it "contains no nodes with a given tag"
  it "contains all nodes without a given tag"
  it "contains all nodes if tag non-existent"
end
require 'spec_helper'

describe "import_urls" do
  class Dummy
  end
  
  before(:all) do
    @dummy = Dummy.new
    @dummy.extend Sinatra::ImportHelpers
  end
  
  let(:stream) { "http://www.google.com\njavascript:alert(a)\n" +
    "http://en.wikipedia.org/\nJean-Paul Sartre" }
  it "should change the db" do
    expect{ @dummy.import_urls(stream) }.to change { Node.count }
  end 
  it "does not insert non-URLs into db" do
    expect{ @dummy.import_urls(stream) }.to change { Node.count }.by(2)
  end
end
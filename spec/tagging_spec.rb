require 'spec_helper'

describe "Tagging: " do
  after(:each) do
    Node.delete_all
  end
  
  describe '/retag/:tag' do
    before(:each) do
      @node = Node.create({url: 'http://localhost/', tagger: "Simon", tag: "other"})
      @node.save
    end
    context "When the tag exists" do
      it "should load the tagging page" do
        get '/retag/other'
        last_response.should be_ok
      end
      it "should display the page to be re-tagged in an iframe"
    end
    
    context "When the tag doesn't exist" do
      it "should not load" do
        get '/retag/nonexistent'
        last_response.should_not be_ok
      end
    end
  end
  
  context "When database is empty (setup)" do
    describe "/" do
      it "should let me set up things"
      it "should redirect me to /import" do
        get '/'
        last_response.should be_redirect
        follow_redirect!
        last_request.url.should include '/import'
      end
    end
    
    describe '/retag/:tag' do
      it "fails" do
        get '/retag/other'
        last_response.should_not be_ok
      end
      it "redirects to root with a message" do
        get '/retag/other'
        last_response.should be_redirect
        follow_redirect!
        last_request.url.should include '/'
        last_request.body.should include "Before you can retag, you must tag some pages first"
      end
    end
    
    describe "/finished" do
      it "redirects to root" do
        get '/finished'
        last_response.should be_redirect
        follow_redirect!
        last_request.url.should include '/'
      end
    end
    
    
  end

  context "When everything has been tagged (teardown)" do
    before(:each) do
      @node = Node.create({url: 'http://localhost/', tagger: "Simon", tag: "other"})
      @node.save
    end
    describe "/" do
      it "should redirect me to /finished" do
        get '/'
        last_response.should be_redirect
        follow_redirect!
        last_request.url.should include '/finished'
      end
    end
    describe "/finished" do
      before(:each) { get '/finished' }
      it "loads" do
        last_response.should be_ok
      end
      it "gives disambiguation of next steps"
    end
    
    describe '/retag' do
      before(:each) do
        get '/retag'
        @tags = Node.uniq.pluck(:tag)
      end
      it "loads" do
        last_response.should be_ok
      end
      it "lists all tags available for retagging" do
        @tags.each do |t|
          last_response.body.should include t
        end
      end
      it "links to routes for retagging of all tags" do
        @tags.each do |t|
          last_response.body.should include '<a href="' + t + '">'
        end
      end
    end
  end

  context "When there are untagged URLs (normal run)" do
    # A lot of situation overlap with "all URLs tagged"
    before(:each) do
      @node = Node.create(url: 'http://localhost/')
      @node.save
    end
    
    describe '/' do
      before(:each) { get '/' }
      it "loads" do
        last_response.should be_ok
      end
      it "displays a yet-untagged page with an iframe" do
        page = last_response.body
        url = page.match('<iframe id="viewer" src="([^"]+)"')[1]
        Node.where("url = ? AND tag != NULL", url).count.should == 0
      end
    end
    
    describe "/list" do
      it "should load" do
        get '/list'
        last_response.should be_ok
      end
      it "should be editable"
    end
    
    describe "/finished" do
      it "redirects to root" do
        get '/finished'
        last_response.should be_redirect
        follow_redirect!
        last_request.url.should include '/'
      end
    end
  end
end


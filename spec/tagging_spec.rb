require 'spec_helper'

describe "Tagging: " do
  after(:each) do
    Node.delete_all
  end

  context "When database is empty (setup)" do
    describe "/" do
      before(:each) { get '/' }
      it "redirects me to /setup" do
        last_response.should be_redirect
        follow_redirect!
        last_request.url.should include '/setup'
      end
        
      it "should redirect me to /import" do
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
          page.has_xpath?("//a[@href='#{t}']")
        end
      end
    end
    
    shared_examples "Functional retag/:tag" do
      context "When the tag exists" do
        before(:each) do
          @node = create(:node, tag: 'other')
          get '/retag/other'
        end
        
        it "loads the tagging page" do
          last_response.should be_ok
        end
        it "displays the URL to be re-tagged in an iframe" do
          page.has_xpath?("//iframe[@src='#{@node.url}']")
        end
      end

      context "When the tag doesn't exist" do
        it "does not load" do
          get '/retag/nonexistent'
          last_response.should_not be_ok
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
      it "loads" do
        get '/'
        last_response.should be_ok
      end
      it "displays a yet-untagged page with an iframe" do
        visit '/'
        url = find("iframe#viewer")['src']
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
    
    describe '/retag/:tag' do
      it_behaves_like "Functional retag/:tag"
    end
  end
end


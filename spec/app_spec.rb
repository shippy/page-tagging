# spec/app_spec.rb
require File.expand_path '../spec_helper.rb', __FILE__

# TODO: use test database

describe "The application" do
  after(:each) do
    Node.delete_all
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
  end

  context "When everything has been tagged (teardown)" do
    before(:each) do
      @node = Node.create({url: 'http://localhost/', tagger: "Simon", tag: "other"})
      @node.save(validate: false)
    end
    describe "/" do
      it "should redirect me to /finished" do
        get '/'
        last_response.should be_redirect
        follow_redirect!
        last_request.url.should include '/finished'
      end
    end
  end

  context "When there are untagged URLs (normal run)" do
    before(:each) do
      @node = Node.create(url: 'http://localhost/')
      @node.save(validate: false)
    end
    
    describe '/' do
      it "should load" do
        get '/'
        last_response.should be_ok
      end
      it "should display a page without a tag in an iframe"
    end
    
    describe "/list" do
      it "should load" do
        get '/list'
        last_response.should be_ok
      end
      it "should be editable"
    end
  end
end


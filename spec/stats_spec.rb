require 'spec_helper'

describe '/stats' do
  context 'has nothing to display' do
    before(:each) do
      get '/stats'
      visit '/stats'
    end
    
    it { last_response.should be_ok }
    it "does not show table" do
      page.should_not have_xpath("//table[@id='ranking']")
    end
  end
  
  context 'has nothing to display' do
    before(:all) do
      50.times do
        node = Node.new(tagger: Faker::Name.name)
        node.save
      end
      get '/stats'
      visit '/stats'
    end
    
    after(:all) do
      Node.delete_all
    end
    
    it { last_response.should be_ok }
    it "shows table" do
      find("table#ranking").should be_true
    end
    it "has as many rows as there are taggers"
  end
end
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "lib", "couch_model", "base"))

class FinderTestModel < CouchModel::Base

  setup_database :url => "http://localhost:5984/test"

  key_accessor :name

end

describe FinderTestModel do

  describe "find" do

    it "should find the model" do
      model = FinderTestModel.find "test_model_1"
      model.should be_instance_of(FinderTestModel)
      model.name.should == "phil"
    end

  end

end

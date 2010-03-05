require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "lib", "couch_model", "base"))

class AssociationTestModel < CouchModel::Base

  setup_database :url => "http://localhost:5984/test"

  key_accessor :name

  belongs_to :related, :class_name => "AssociationTestModel"

end

describe AssociationTestModel do

  before :each do
    @model = AssociationTestModel.find "test_model_1"
  end

  describe "belongs_to" do

    it "should define the :related_id accessor methods" do
      @model.should respond_to(:related_id)
      @model.should respond_to(:related_id=)
    end

    it "should define the :related method" do
      @model.should respond_to(:related)
    end

  end

  describe "related" do

    it "should return a model" do
      @model.related.should be_instance_of(AssociationTestModel)
    end

  end

  describe "related=" do

    before :each do
      @other = AssociationTestModel.find "test_model_2"
    end

    it "should set the relation to nil" do
      @model.related_id = "test"
      @model.related = nil
      @model.related_id.should be_nil
    end

    it "should set the relation" do
      @model.related = @other
      @model.related_id.should == "test_model_2"
    end

    it "should raise an ArgumentError on wrong class" do
      lambda do
        @model.related = "test"
      end.should raise_error(ArgumentError)
    end

  end

end

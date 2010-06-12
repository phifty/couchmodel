require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "lib", "couch_model", "base"))

CouchModel::Configuration.design_directory = File.join File.dirname(__FILE__), "design"

class BaseTestModel < CouchModel::Base

  setup_database :url => "http://localhost:5984/test"

  key_accessor :name

end

describe BaseTestModel do

  before :each do
    @model = BaseTestModel.new :id => "test_model_1"
  end

  describe "attributes=" do

    it "should convert an :id or 'id' key to '_id'" do
      @model.attributes = { :id => "test" }
      @model.attributes.should == { "_id" => "test", CouchModel::Configuration::CLASS_KEY => "BaseTestModel" }
    end

  end

  describe "==" do

    before :each do
      @other = BaseTestModel.new
      @other.id = "test_model_1"
    end

    it "should be true if the id's of the models are equal" do
      @model.should == @other
    end

    it "should be false if the id's of the models are not equal" do
      @other.id = "invalid"
      @model.should_not == @other
    end

  end

  describe "new?" do

    it "should be true on new model" do
      BaseTestModel.new.should be_new
    end

    it "should be false on existing model" do
      BaseTestModel.find("test_model_1").should_not be_new
    end
    
  end

  describe "load" do

    before :each do
      @model = BaseTestModel.new :id => "test_model_1"
    end

    it "should load the model" do
      @model.load
      @model.attributes["name"].should == "phil"
    end

    it "should raise an NotFoundError if the model id is not existing" do
      @model.id = "invalid"
      lambda do
        @model.load
      end.should raise_error(CouchModel::Base::NotFoundError)
    end

  end

  describe "save" do

    def do_save
      @model.save
    end

    describe "a new model" do

      before :each do
        @model = BaseTestModel.new
      end

      it "should return true if the model has been saved" do
        do_save.should be_true
      end

      it "should return false on wrong status code" do
        Transport::JSON.stub!(:request).and_raise(Transport::JSON::UnexpectedStatusCodeError.new(404))
        do_save.should be_false
      end

    end

    describe "an existing model" do

      before :each do
        @model = BaseTestModel.find "test_model_1"
      end

      it "should return true if the model has been updated" do
        do_save.should be_true
      end

      it "should return false on wrong status code" do
        Transport::JSON.stub!(:request).and_raise(Transport::JSON::UnexpectedStatusCodeError.new(404))
        do_save.should be_false
      end

    end

  end

  describe "destroy" do

    def do_destroy
      @model.destroy
    end

    describe "on a new model" do

      it "should return false" do
        do_destroy.should be_false
      end

    end

    describe "on an existing model" do

      before :each do
        @model.load
      end

      it "should return true if the model has been destroyed" do
        do_destroy.should be_true
      end

      it "should raise NotFoundError on wrong status code" do
        Transport::JSON.stub!(:request).and_raise(Transport::JSON::UnexpectedStatusCodeError.new(404))
        lambda do
          do_destroy
        end.should raise_error(CouchModel::Base::NotFoundError)
      end

      it "should be new afterwards" do
        do_destroy
        @model.should be_new
      end

    end
    
  end

  describe "all" do

    it "should return a collection for the class view" do
      BaseTestModel.all.should be_instance_of(CouchModel::Collection)
    end

  end

  describe "create" do

    it "should return a new created model" do
      model = BaseTestModel.create :id => "test_model_1"
      model.should be_instance_of(BaseTestModel)
      model.should_not be_new
    end

    it "should return nil on error" do
      Transport::JSON.stub!(:request).and_raise(Transport::JSON::UnexpectedStatusCodeError.new(500))
      model = BaseTestModel.create :id => "test_model_1"
      model.should be_nil
    end

  end

  describe "destroy_all" do

    before :each do
      BaseTestModel.stub!(:all).and_return([ @model ])
    end

    it "should destroy all documents of the class" do
      @model.should_receive(:destroy)
      BaseTestModel.destroy_all
    end

  end

end

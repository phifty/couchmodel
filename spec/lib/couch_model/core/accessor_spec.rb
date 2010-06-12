require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "lib", "couch_model", "base"))

class AccessorTestModel < CouchModel::Base

  setup_database :url => "http://localhost:5984/test"

  key_reader   :test_one,   :default => "test default"
  key_writer   :test_two,   :default => "test default"
  key_accessor :test_three, :default => "test default"
end

describe AccessorTestModel do

  before :each do
    @model = AccessorTestModel.new :id => "test_model_1"
  end

  describe "key_reader" do

    before :each do
      @model = AccessorTestModel.new
    end

    it "should define a reader method" do
      @model.should respond_to(:test_one)
    end

    it "should set a default value" do
      @model.test_one.should == "test default"
    end

    it "should raise an exception if the reader method is already defined" do
      lambda do
        AccessorTestModel.key_reader :test_one
      end.should raise_error(ArgumentError)
    end

  end

  describe "key_writer" do

    before :each do
      @model = AccessorTestModel.new
    end

    it "should define a writer method" do
      @model.should respond_to(:test_two=)
    end

    it "should set a default value" do
      AccessorTestModel.defaults["test_two"].should == "test default"
    end

    it "should raise an exception if the writer method is already defined" do
      lambda do
        AccessorTestModel.key_writer :test_two
      end.should raise_error(ArgumentError)
    end

  end

  describe "key_accessor" do

    before :each do
      @model = AccessorTestModel.new
    end

    it "should define a reader method" do
      @model.should respond_to(:test_three)
    end

    it "should define a writer method" do
      @model.should respond_to(:test_three=)
    end

  end

end
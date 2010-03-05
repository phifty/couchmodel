require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "lib", "couch_model", "base"))

class AccessorTestModel < CouchModel::Base

  setup_database :url => "http://localhost:5984/test"

end

describe AccessorTestModel do

  before :each do
    @model = AccessorTestModel.new :id => "test_model_1"
  end

  describe "key_reader" do

    before :each do
      AccessorTestModel.key_reader :test
      @model = AccessorTestModel.new
    end

    it "should define a reader method" do
      @model.should respond_to(:test)
    end

  end

  describe "key_writer" do

    before :each do
      AccessorTestModel.key_writer :test
      @model = AccessorTestModel.new
    end

    it "should define a writer method" do
      @model.should respond_to(:test=)
    end

  end

  describe "key_accessor" do

    before :each do
      AccessorTestModel.key_accessor :test
      @model = AccessorTestModel.new
    end

    it "should define a reader method" do
      @model.should respond_to(:test)
    end

    it "should define a writer method" do
      @model.should respond_to(:test=)
    end

  end

end
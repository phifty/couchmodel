require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "lib", "couch_model", "base"))

class AccessorTestModel < CouchModel::Base

  setup_database :url => "http://localhost:5984/test"

  key_reader   :test_one,   :default => "test default"
  key_writer   :test_two,   :default => "test default"
  key_accessor :test_three, :default => "test default"

  key_accessor :test_integer, :type => :integer
  key_accessor :test_string,  :type => :string
  key_accessor :test_date,    :type => :date
  key_accessor :test_time,    :type => :time

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

    it "should raise an ArgumentError on unsupported type" do
      lambda do
        AccessorTestModel.key_reader :test, :type => :unsupported
      end.should raise_error(ArgumentError)
    end

    it "should define readers for integer types" do
      @model.test_integer = 3
      @model.test_integer.should be_instance_of(Fixnum)
    end

    it "should define readers for string types" do
      @model.test_string = "3"
      @model.test_string.should be_instance_of(String)
    end

    it "should define readers for date types" do
      @model.test_date = Date.today
      @model.test_date.should be_instance_of(Date)
    end

    it "should define readers for time types" do
      @model.test_time = Time.now
      @model.test_time.should be_instance_of(Time)
    end

    it "should raise an ArgumentError if the reader method is already defined" do
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

    it "should raise an ArgumentError on unsupported type" do
      lambda do
        AccessorTestModel.key_writer :test, :type => :unsupported
      end.should raise_error(ArgumentError)
    end

    it "should define writers for integer types" do
      @model.test_integer = 3
      @model.attributes["test_integer"].should == 3
    end

    it "should define writers for string types" do
      @model.test_string = "3"
      @model.attributes["test_string"].should == "3"
    end

    it "should define writers for date types" do
      @model.test_date = Date.parse("2010-07-07")
      @model.attributes["test_date"].should == "2010-07-07"
    end

    it "should define writers for time types" do
      @model.test_time = Time.parse("2010-07-07 10:10:10")
      @model.attributes["test_time"].should == "2010-07-07 10:10:10 +0200"
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

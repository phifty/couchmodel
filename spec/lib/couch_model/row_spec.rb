require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "lib", "couch_model", "base"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "lib", "couch_model", "row"))

class RowTestModel < CouchModel::Base

  key_accessor :name

end

describe CouchModel::Row do

  before :each do
    @hash = {
      "id"    => "test id",
      "key"   => "test key",
      "value" => "test value",
      "doc"   => {
        "_id"                                 => "test doc id",
        CouchModel::Configuration::CLASS_KEY  => "RowTestModel",
        "name"                                => "test doc name"
      }
    }
    @row = CouchModel::Row.new @hash
  end

  describe "initialize" do

    it "should assign the id" do
      @row.id.should == "test id"
    end

    it "should assign the key" do
      @row.key.should == "test key"
    end

    it "should assign the id" do
      @row.value.should == "test value"
    end

    it "should assign the document" do
      @row.document.should == {
        "_id"                                 => "test doc id",
        CouchModel::Configuration::CLASS_KEY  => "RowTestModel",
        "name"                                => "test doc name"
      }
    end

  end

  describe "model" do

    it "should return a casted model" do
      @row.model.should be_instance_of(RowTestModel)
    end

    it "should set the model's values" do
      @row.model.id.should == "test doc id"
      @row.model.name.should == "test doc name"
    end

    it "should raise a StandardError if model_class isn't defined" do
      @row.document[CouchModel::Configuration::CLASS_KEY] = "invalid"
      lambda do
        @row.model
      end.should raise_error(StandardError)
    end

  end

end

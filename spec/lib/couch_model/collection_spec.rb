require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "lib", "couch_model", "base"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "lib", "couch_model", "collection"))

CouchModel::Configuration.design_directory = File.join File.dirname(__FILE__), "design"

class CollectionTestModel < CouchModel::Base

  setup_database :url => "http://localhost:5984/test"

  key_accessor :name

end

describe CouchModel::Collection do

  before :each do
    @database = CouchModel::Database.new :name => "test"
    @collection = @database.documents :limit => 1
  end

  describe "initialize" do

    before :each do
      @collection = CouchModel::Collection.new @database.url + "/_all_docs", :option => "test"
    end

    it "should set the url" do
      @collection.url.should == @database.url + "/_all_docs"
    end

    it "should set the options" do
      @collection.options.should == { :option => "test" }
    end

  end

  describe "total_count" do

    describe "without a previously performed fetch" do

      it "should perform a meta fetch (with a limit of zero)" do
        CouchModel::Transport.should_receive(:request).with(anything, anything,
          hash_including(:parameters => { "include_docs" => "true", "limit" => "0" }))
        @collection.total_count
      end

      it "should return the total count" do
        @collection.total_count.should == 1
      end

    end

    describe "with a previously performed fetch" do

      before :each do
        @collection.first # perform the fetch
      end

      it "should not perform another fetch" do
        CouchModel::Transport.should_not_receive(:request)
        @collection.total_count
      end

      it "should return the total count" do
        @collection.total_count.should == 1
      end

    end

  end

  describe "fetch" do

    def do_fetch
      @collection.send :fetch
    end

    it "should return true" do
      do_fetch.should be_true
    end

    it "should fetch the model" do
      do_fetch
      @collection.first.should be_instance_of(CollectionTestModel)
      @collection.first.name.should == "phil"
    end

  end

  describe "request_parameters" do

    it "should convert options to request parameters" do
      parameters = @collection.send :request_parameters
      parameters.should == { "include_docs" => "true", "limit" => "1" }
    end

  end

end

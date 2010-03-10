require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "lib", "couch_model", "database"))

describe CouchModel::Database do

  before :each do
    @database = CouchModel::Database.new :name => "test"
  end

  describe "==" do

    before :each do
      @other = CouchModel::Database.new :name => "test"
    end

    it "should be true when comparing two equal databases" do
      @database.should == @other
    end

    it "should be false when comparing two different databases" do
      @other = CouchModel::Database.new :name => "other"
      @database.should_not == @other
    end

    it "should be false when comparing two databases with on different servers" do
      @other = CouchModel::Database.new :name => "test", :server => CouchModel::Server.new(:host => "other")
      @database.should_not == @other
    end

  end

  describe "===" do

    before :each do
      @other = CouchModel::Database.new :name => "test"
    end

    it "should be true when comparing a database object with itself" do
      @database.should === @database
    end

    it "should be false when comparing a database object with another database object" do
      @database.should_not === @other
    end

  end

  describe "create!" do

    before :each do
      @response = { :code => "201" }
      CouchModel::Transport.stub!(:request).and_return(@response)
    end

    it "should create the database" do
      CouchModel::Transport.should_receive(:request).with(:put, /test$/, anything).and_return(@response)
      @database.create!
    end

  end

  describe "create_if_missing!" do

    before :each do
      @database.stub!(:create!)      
    end

    it "should not call create! if the database exists" do
      @database.stub!(:exists?).and_return(true)
      @database.should_not_receive(:create!)
      @database.create_if_missing!
    end

    it "should call create! if the database not exists" do
      @database.stub!(:exists?).and_return(false)
      @database.should_receive(:create!)
      @database.create_if_missing!
    end

  end

  describe "delete!" do

    before :each do
      @response = { :code => "200" }
      CouchModel::Transport.stub!(:request).and_return(@response)
    end

    it "should delete the database" do
      CouchModel::Transport.should_receive(:request).with(:delete, /test$/, anything).and_return(@response)
      @database.delete!
    end

  end

  describe "delete_if_exists!" do

    before :each do
      @database.stub!(:delete!)
    end

    it "should call delete! if the database exists" do
      @database.stub!(:exists?).and_return(true)
      @database.should_receive(:delete!)
      @database.delete_if_exists!
    end

    it "should not call delete! if the database not exists" do
      @database.stub!(:exists?).and_return(false)
      @database.should_not_receive(:delete!)
      @database.delete_if_exists!
    end

  end

  describe "informations" do

    it "should return database informations" do
      informations = @database.informations
      informations.should have_key("db_name")
      informations.should have_key("doc_count")
    end

  end

  describe "exists?" do

    it "should be true" do
      @database.exists?.should be_true
    end

    it "should be false if no database with the given name exists" do
      database = CouchModel::Database.new :name => "invalid"
      database.exists?.should be_false
    end

  end

  describe "documents" do

    it "should return a collection" do
      @database.documents.should be_instance_of(CouchModel::Collection)
    end

  end

end

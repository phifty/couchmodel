require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "lib", "couch_model"))

CouchModel::Configuration.design_directory = File.join File.dirname(__FILE__), "design"

class TestUser < CouchModel::Base

  setup_database :url => "http://localhost:5984/test"

  key_accessor :username
  key_accessor :email

end

TestUser.database.delete! if TestUser.database.exists?
CouchModel::Configuration.setup_databases
CouchModel::Configuration.setup_designs

describe TestUser do

  use_real_transport!

  before :each do
    @user = TestUser.new :username => "user", :email => "email"
  end

  describe "setup" do

    it "should have been created the database" do
      TestUser.database.exists?.should be_true
    end

    it "should have been created the design" do
      TestUser.design.exists?.should be_true
    end

  end

  describe "save" do

    it "should create the model" do
      @user.save
      @user.should_not be_new
    end

  end

  describe "all" do

    before :each do
      @user.save
    end

    it "should include the saved user" do
      TestUser.all.should include(@user)
    end

  end

end

require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "models"))

describe "integration" do

  use_real_transport!

  before :each do
    @user = User.new :username => "user"
  end

  describe "setup" do

    it "should have been created the database" do
      User.database.exists?.should be_true
    end

    it "should have been created the design" do
      User.design.exists?.should be_true
    end

    it "should setup unique databases" do
      User.database.should === Membership.database
    end

    it "should setup designs for each model" do
      User.design.should_not == Membership.design
    end

  end

  describe "save" do

    it "should create the model" do
      @user.save
      @user.should_not be_new
    end

    it "should return true" do
      @user.save.should be_true
    end

  end

end

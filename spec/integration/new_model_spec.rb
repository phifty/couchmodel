require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "models"))

describe "integration" do

  use_real_transport!

  before :each do
    @user = User.new "username" => "user",
                     "birthday(1i)" => "2010",
                     "birthday(2i)" => "3",
                     "birthday(3i)" => "15",
                     "lunch(1i)" => "2010",
                     "lunch(2i)" => "10",
                     "lunch(3i)" => "21",
                     "lunch(4i)" => "12",
                     "lunch(5i)" => "13",
                     "lunch(6i)" => "14"
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

  describe "birthday" do

    it "should return the correct date" do
      @user.birthday.should == Date.parse("2010/03/15")
    end

  end

  describe "lunch" do

    it "should return the correct time" do
      @user.lunch.should == Time.parse("2010/10/21 12:13:14")
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

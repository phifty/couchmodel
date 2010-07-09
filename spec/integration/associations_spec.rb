require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "models"))

describe "integration" do

  use_real_transport!

  before :each do
    create_users_and_memberships
  end

  describe "belongs_to" do

    it "should return the related model" do
      @membership_one.user.should == @user_one
      @membership_two.user.should == @user_two
    end

  end

  describe "has_many" do

    it "should include the related model" do
      @user_one.memberships.should include(@membership_one)
      @user_two.memberships.should include(@membership_two)
    end

    it "should not include the not-related model" do
      @user_one.memberships.should_not include(@membership_two)
      @user_two.memberships.should_not include(@membership_one)
    end

    it "should use the selector" do
      @user_one.memberships(Time.parse("2010-07-07").strftime("%Y-%m-%d %H:%M:%S %z")).should include(@membership_one)
      @user_one.memberships(Time.parse("2010-07-08").strftime("%Y-%m-%d %H:%M:%S %z")).should_not include(@membership_one)
    end

  end

end

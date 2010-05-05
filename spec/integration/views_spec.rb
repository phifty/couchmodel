require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "models"))

describe "integration" do

  use_real_transport!

  before :each do
    create_users_and_memberships
  end

  describe "all" do

    it "should include the saved user" do
      begin
        User.all.should include(@user_one)
      rescue Object => error
        puts error.backtrace
        raise error
      end
      User.all.should include(@user_two)
    end

  end

  describe "user_count" do

    before :each do
      @rows = User.user_count :returns => :rows
    end

    it "should return the user count" do
      @rows.first.value.should >= 2
    end

  end

end

require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "lib", "couch_model"))

CouchModel::Configuration.design_directory = File.join File.dirname(__FILE__), "design"

class User < CouchModel::Base

  setup_database :url => "http://localhost:5984/test", :setup_on_initialization => true, :delete_if_exists => true

  key_accessor :username
  key_accessor :email

  has_many :memberships,
           :class_name  => "Membership",
           :view_name   => :by_user_id_and_created_at,
           :query       => lambda { |created_at| { :startkey => [ self.id, (created_at || nil) ], :endkey => [ self.id, (created_at || { }) ] } }

end

class Membership < CouchModel::Base

  setup_database :url => "http://localhost:5984/test", :setup_on_initialization => true, :delete_if_exists => true

  key_accessor :created_at

  belongs_to :user, :class_name => "User"

end

describe "integration" do

  use_real_transport!

  context "on new models" do

    before :each do
      @user = User.new :username => "user", :email => "email"
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

    end

  end

  context "on saved models" do

    before :each do
      @user_one = User.new :username => "user one", :email => "email one"
      @user_one.save
      @user_two = User.new :username => "user two", :email => "email two"
      @user_two.save
      @membership_one = Membership.new :created_at => "yesterday"
      @membership_one.user = @user_one
      @membership_one.save
      @membership_two = Membership.new :created_at => "yesterday"
      @membership_two.user = @user_two
      @membership_two.save
    end

    describe "all" do

      it "should include the saved user" do
        User.all.should include(@user_one)
        User.all.should include(@user_two)
      end

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
        @user_one.memberships("yesterday").should include(@membership_one)
        @user_one.memberships("today").should_not include(@membership_one)
      end

    end

  end

end

require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "lib", "couch_model"))

CouchModel::Configuration.design_directory = File.join File.dirname(__FILE__), "design"

class User < CouchModel::Base

  setup_database :url => "http://localhost:5984/test", :setup_on_initialization => true, :delete_if_exists => true

  key_accessor :username
  key_accessor :email

end

class Membership < CouchModel::Base

  setup_database :url => "http://localhost:5984/test", :setup_on_initialization => true, :delete_if_exists => true

  belongs_to :user, :class_name => User.to_s

end

describe "Integration" do

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
      @user = User.new :username => "user", :email => "email"
      @user.save
      @membership = Membership.new
      @membership.user = @user
      @membership.save
    end

    describe "all" do

      it "should include the saved user" do
        User.all.should include(@user)
      end

    end

    describe "belongs_to" do

      it "should return the related model" do
        @membership.user.should == @user
      end

    end

  end

end

require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "lib", "couch_model", "base"))

CouchModel::Configuration.design_directory = File.join File.dirname(__FILE__), "..", "design"

class SetupTestModel < CouchModel::Base

  setup_database :url => "http://localhost:5984/test"

end

describe SetupTestModel do

  describe "setup_database" do

    before :each do
      @design = SetupTestModel.design
      @design.stub!(:push)
      CouchModel::Design.stub!(:new).and_return(@design)

      @options = { :url => "http://localhost:5984/test" }
    end

    def do_setup
      SetupTestModel.setup_database @options
    end

    it "should initialize the database" do
      do_setup
      SetupTestModel.database.url.should == @options[:url]
    end

    it "should register the database" do
      do_setup
      CouchModel::Configuration.databases.should include(SetupTestModel.database)
    end

    it "should register just one database if two databases has been set up" do
      database = SetupTestModel.database
      do_setup
      database.object_id.should == SetupTestModel.database.object_id
    end

    it "should delete the database if requested" do
      @options[:delete_if_exists] = true
      database = SetupTestModel.database
      database.should_receive(:delete_if_exists!)
      CouchModel::Database.stub!(:new).and_return(database)
      do_setup
    end

    it "should create the database if requested" do
      @options[:create_if_missing] = true
      database = SetupTestModel.database
      database.should_receive(:create_if_missing!)
      CouchModel::Database.stub!(:new).and_return(database)
      do_setup
    end

    it "should initialize the design" do
      do_setup
      SetupTestModel.design.should be_instance_of(CouchModel::Design)
    end

    it "should register the design" do
      do_setup
      CouchModel::Configuration.designs.should include(SetupTestModel.design)
    end

    it "should generate the class view" do
      do_setup
      SetupTestModel.design.views.first.name.should == CouchModel::Configuration::CLASS_VIEW_NAME
    end

    it "should define the view methods" do
      do_setup
      SetupTestModel.should respond_to(:test_view)
      SetupTestModel.test_view.should be_instance_of(CouchModel::Collection)
    end

    it "should push the design if requested" do
      @options[:push_design] = true
      @design.should_receive(:push)
      do_setup
    end

    it "should raise an ArgumentError on missing url option" do
      @options[:url] = nil
      lambda do
        do_setup
      end.should raise_error(ArgumentError)
    end

  end

end

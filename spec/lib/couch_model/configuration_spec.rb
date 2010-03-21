require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "lib", "couch_model", "configuration"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "lib", "couch_model", "database"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "lib", "couch_model", "design"))

describe CouchModel::Configuration do

  describe "design_directory=" do

    it "should set the design directory" do
      CouchModel::Configuration.design_directory = "test"
      CouchModel::Configuration.design_directory.should == "test"
    end

  end

  describe "register_database" do

    before :each do
      CouchModel::Configuration.databases.clear
      @database = CouchModel::Database.new :name => "test"
      @other = CouchModel::Database.new :name => "test"
    end

    def do_register
      CouchModel::Configuration.register_database @database
    end

    it "should add the database" do
      do_register
      CouchModel::Configuration.databases.should include(@database)
    end

    it "should return a database with equal parameters if such is added before" do
      CouchModel::Configuration.register_database @other
      do_register.object_id.should == @other.object_id
    end

  end

  describe "setup_databases" do

    before :each do
      CouchModel::Configuration.instance_variable_set :@databases, [ ]
      @database = CouchModel::Database.new :name => "test"
      CouchModel::Configuration.register_database @database

      @database.stub!(:delete_if_exists!)
      @database.stub!(:create_if_missing!)
    end

    def do_setup
      CouchModel::Configuration.setup_databases :delete_if_exists => true, :create_if_missing => true
    end

    it "should call delete_if_exists!" do
      @database.should_receive(:delete_if_exists!)
      do_setup
    end

    it "should call create_if_missing!" do
      @database.should_receive(:create_if_missing!)
      do_setup
    end

  end

  describe "register_design" do

    before :each do
      CouchModel::Configuration.designs.clear
      @database = CouchModel::Database.new :name => "test"
      @design = CouchModel::Design.new @database, :id => "test_design"
    end

    it "should add the design" do
      CouchModel::Configuration.register_design @design
      CouchModel::Configuration.designs.should include(@design)
    end

  end

  describe "setup_designs" do

    before :each do
      CouchModel::Configuration.instance_variable_set :@designs, [ ]

      @database = CouchModel::Database.new :name => "test"
      @design = CouchModel::Design.new @database, :id => "test_design"
      CouchModel::Configuration.register_design @design
    end

    def do_setup
      CouchModel::Configuration.setup_designs
    end
    
    it "should push the design" do
      @design.should_receive(:push)
      do_setup
    end

  end

end

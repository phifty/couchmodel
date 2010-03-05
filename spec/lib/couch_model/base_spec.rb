require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "lib", "couch_model", "base"))

CouchModel::Configuration.design_directory = File.join File.dirname(__FILE__), "design"

class BaseTestModel < CouchModel::Base

  setup_database :url => "http://localhost:5984/test"

  key_accessor :name

end

describe BaseTestModel do

  before :each do
    @model = BaseTestModel.new :id => "test_model_1"
  end

  describe "setup_database" do

    before :each do
      @design = BaseTestModel.design
      @design.stub!(:push)
      CouchModel::Design.stub!(:new).and_return(@design)

      @options = { :url => "http://localhost:5984/test" }
    end

    def do_setup
      BaseTestModel.setup_database @options
    end

    it "should initialize the database" do
      do_setup
      BaseTestModel.database.url.should == @options[:url]
    end

    it "should register the database" do
      do_setup
      CouchModel::Configuration.databases.should include(BaseTestModel.database)
    end

    it "should register just one database if two databases has been set up" do
      database = BaseTestModel.database
      do_setup
      database.object_id.should == BaseTestModel.database.object_id
    end

    it "should setup the database on initialization if requested" do
      @options[:setup_on_initialization] = true
      database = BaseTestModel.database
      database.should_receive(:setup!).with(@options)
      CouchModel::Database.stub!(:new).and_return(database)
      do_setup
    end

    it "should initialize the design" do
      do_setup
      BaseTestModel.design.should be_instance_of(CouchModel::Design)
    end

    it "should register the design" do
      do_setup
      CouchModel::Configuration.designs.should include(BaseTestModel.design)
    end

    it "should generate the class view" do
      do_setup
      BaseTestModel.design.views.first.name.should == CouchModel::Configuration::CLASS_VIEW_NAME
    end

    it "should define the view methods" do
      do_setup
      BaseTestModel.should respond_to(:test_view)
      BaseTestModel.test_view.should be_instance_of(CouchModel::Collection)
    end

    it "should push the design on initialization if requested" do
      @options[:setup_on_initialization] = true
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

  describe "key_reader" do

    before :each do
      BaseTestModel.key_reader :test
      @model = BaseTestModel.new
    end

    it "should define a reader method" do
      @model.should respond_to(:test)
    end

  end

  describe "key_writer" do

    before :each do
      BaseTestModel.key_writer :test
      @model = BaseTestModel.new
    end

    it "should define a writer method" do
      @model.should respond_to(:test=)
    end

  end

  describe "key_accessor" do

    before :each do
      BaseTestModel.key_accessor :test
      @model = BaseTestModel.new
    end

    it "should define a reader method" do
      @model.should respond_to(:test)
    end

    it "should define a writer method" do
      @model.should respond_to(:test=)
    end

  end

  describe "attributes=" do

    it "should convert an :id or 'id' key to '_id'" do
      @model.attributes = { :id => "test" }
      @model.attributes.should == { "_id" => "test", CouchModel::Configuration::CLASS_KEY => "BaseTestModel" }
    end

  end

  describe "==" do

    before :each do
      @other = BaseTestModel.new
      @other.id = "test_model_1"
    end

    it "should be true if the id's of the models are equal" do
      @model.should == @other
    end

    it "should be false if the id's of the models are not equal" do
      @other.id = "invalid"
      @model.should_not == @other
    end

  end

  describe "new?" do

    it "should be true on new model" do
      BaseTestModel.new.should be_new
    end

    it "should be false on existing model" do
      BaseTestModel.find("test_model_1").should_not be_new
    end
    
  end

  describe "load" do

    before :each do
      @model = BaseTestModel.new :id => "test_model_1"
    end

    it "should load the model" do
      @model.load
      @model.attributes["name"].should == "phil"
    end

    it "should raise an NotFoundError if the model id is not existing" do
      @model.id = "invalid"
      lambda do
        @model.load
      end.should raise_error(CouchModel::Base::NotFoundError)
    end

  end

  describe "save" do

    def do_save
      @model.save
    end

    describe "a new model" do

      before :each do
        @model = BaseTestModel.new
      end

      it "should return true if the model has been saved" do
        do_save.should be_true
      end

      it "should return false on wrong status code" do
        CouchModel::Transport.stub!(:request).and_raise(CouchModel::Transport::UnexpectedStatusCodeError.new(404))
        do_save.should be_false
      end

    end

    describe "an existing model" do

      before :each do
        @model = BaseTestModel.find "test_model_1"
      end

      it "should return true if the model has been updated" do
        do_save.should be_true
      end

      it "should return false on wrong status code" do
        CouchModel::Transport.stub!(:request).and_raise(CouchModel::Transport::UnexpectedStatusCodeError.new(404))
        do_save.should be_false
      end

    end

  end

  describe "destroy" do

    def do_destroy
      @model.destroy
    end

    describe "on a new model" do

      it "should return false" do
        do_destroy.should be_false
      end

    end

    describe "on an existing model" do

      before :each do
        @model.load
      end

      it "should return true if the model has been destroyed" do
        do_destroy.should be_true
      end

      it "should raise NotFoundError on wrong status code" do
        CouchModel::Transport.stub!(:request).and_raise(CouchModel::Transport::UnexpectedStatusCodeError.new(404))
        lambda do
          do_destroy
        end.should raise_error(CouchModel::Base::NotFoundError)
      end

      it "should be new afterwards" do
        do_destroy
        @model.should be_new
      end

    end
    
  end

  describe "all" do

    it "should return a collection for the class view" do
      BaseTestModel.all.should be_instance_of(CouchModel::Collection)
    end
    
  end

  describe "find" do

    it "should find the model" do
      model = BaseTestModel.find "test_model_1"
      model.should be_instance_of(BaseTestModel)
      model.name.should == "phil"
    end
    
  end

end

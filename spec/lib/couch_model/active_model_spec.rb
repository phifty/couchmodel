require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "lib", "couch_model", "active_model"))

class ActiveTestModel < CouchModel::Base

  setup_database :url => "http://localhost:5984/test"

  key_accessor :name
  key_accessor :email

  validates_presence_of :name

  before_initialize :initialize_callback
  before_save       :save_callback
  before_create     :create_callback
  before_update     :update_callback
  before_destroy    :destroy_callback

  attr_reader :initialized

  def initialize_callback
    @initialized = true
  end

  def save_callback; end
  def create_callback; end
  def update_callback; end
  def destroy_callback; end

end

describe ActiveTestModel do
  include ActiveModel::Lint::Tests

  before :each do
    @model = ActiveTestModel.new :id => "test_model_1"
  end

  describe "initialize" do

    it "should call the initialize callback" do
      @model.initialized.should be_true
    end

  end

  describe "new_record?" do

    it "should fullfill the lint test" do
      test_new_record?
    end

  end

  describe "destroyed?" do

    it "should fullfill the lint test" do
      test_destroyed?
    end

    it "should return true if model is new" do
      @model.stub!(:new?).and_return(true)
      @model.should be_destroyed
    end

  end

  describe "naming" do

    it "should fullfill the lint test" do
      test_model_naming
    end

  end

  describe "valid?" do

    it "should be true with a given name" do
      @model.name = "test"
      @model.should be_valid
    end

    it "should be false without a given name" do
      @model.name = ""
      @model.should_not be_valid
    end

  end

  describe "changed?" do

    it "should be true if a attribute has changed" do
      @model.name = "test"
      @model.should be_changed
    end

  end

  describe "name_changed?" do

    it "should be true if the attribute has changed" do
      @model.name = "test"
      @model.should be_name_changed
    end

    it "should be false if another attribute has changed" do
      @model.email = "test"
      @model.should_not be_name_changed
    end

  end

  describe "reset_name!" do

    before :each do
      @model.name = "test"
    end

    it "should reset the attributes" do
      @model.reset_name!
      @model.name.should be_nil
    end

  end

  describe "to_param" do

    it "should return the model's id" do
      @model.to_param.should == @model.id
    end

  end
  
  describe "save" do

    before :each do
      @model.name = "test"
    end

    it "should commit the changes" do
      @model.save
      @model.should_not be_changed
    end

    it "should call the save callback" do
      @model.should_receive(:save_callback)
      @model.save
    end

    it "should not save on failing validations" do
      @model.name = ""
      @model.save.should be_false
    end

    describe "on a new model" do

      before :each do
        @model.stub!(:new?).and_return(true)
      end

      it "should call the create callback" do
        @model.should_receive(:create_callback)
        @model.save
      end

    end

    describe "on an existing model" do

      before :each do
        @model.stub!(:new?).and_return(false)
      end

      it "should call the update callback" do
        @model.should_receive(:update_callback)
        @model.save
      end

    end

  end

  describe "save!" do

    before :each do
      @model.name = "test"
    end

    it "should commit the changes" do
      @model.save!
      @model.should_not be_changed
    end

    it "should raise InvalidModelError on failing validations" do
      @model.name = ""
      lambda do
        @model.save!
      end.should raise_error(CouchModel::Base::InvalidModelError)
    end

    it "should raise StandardError on all other errors" do
      @model.stub!(:save).and_return(false)
      lambda do
        @model.save!
      end.should raise_error(StandardError)
    end

  end

  describe "create!" do

    it "should create a model" do
      model = ActiveTestModel.create! :id => "test_model_1", :name => "test"
      model.should be_instance_of(ActiveTestModel)
      model.should_not be_new
    end

    it "should raise InvalidModelError on failing validations" do
      lambda do
        ActiveTestModel.create! :id => "test_model_1", :name => ""
      end.should raise_error(CouchModel::Base::InvalidModelError)
    end

  end

  describe "destroy" do

    def do_destroy
      @model.destroy
    end

    it "should call the destroy callback" do
      @model.should_receive(:destroy_callback)
      do_destroy
    end
    
  end

  describe "to_json" do

    before :each do
      @model.name = "test"
      @model.email = "test"
    end

    it "should return all attributes as json" do
      @model.to_json.should == "{\"_id\":\"test_model_1\",\"email\":\"test\",\"model_class\":\"ActiveTestModel\",\"name\":\"test\"}"
    end

  end

  describe "to_xml" do

    before :each do
      @model.name = "test"
      @model.email = "test"
    end
    
    it "should return all attributes as xml" do
      @model.to_xml.should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<active-test-model>\n  <-id>test_model_1</-id>\n  <email>test</email>\n  <model-class>ActiveTestModel</model-class>\n  <name>test</name>\n</active-test-model>\n"
    end

  end

  describe "human_attribute_name" do

    it "should return a human readable attribute name" do
      ActiveTestModel.human_attribute_name("name").should == "Name"
    end

  end

  private

  def assert(condition, message = nil)
    puts message unless condition
    condition.should be_true
  end

  def assert_kind_of(klass, value)
    value.should be_kind_of(klass)
  end

end

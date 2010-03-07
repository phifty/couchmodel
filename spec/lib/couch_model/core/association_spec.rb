require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "lib", "couch_model", "base"))

CouchModel::Configuration.design_directory = File.join File.dirname(__FILE__), "..", "design"

class AssociationTestModelOne < CouchModel::Base

  setup_database :url => "http://localhost:5984/test"

  key_accessor :name

  belongs_to :related, :class_name => "AssociationTestModelTwo"

end

class AssociationTestModelTwo < CouchModel::Base

  setup_database :url => "http://localhost:5984/test"

  key_accessor :name

  has_many :related,
           :class_name  => "AssociationTestModelOne",
           :view_name   => :by_related_id_and_name,
           :query       => lambda { |name| { :startkey => [ self.id, (name || nil) ], :endkey => [ self.id, (name || { }) ] } }

end

describe AssociationTestModelOne do

  before :each do
    @model = AssociationTestModelOne.find "test_model_1"
  end

  describe "belongs_to" do

    it "should define the :related_id accessor methods" do
      @model.should respond_to(:related_id)
      @model.should respond_to(:related_id=)
    end

    it "should define the :related method" do
      @model.should respond_to(:related)
    end

  end

  describe "related" do

    it "should return a model" do
      @model.related.should be_instance_of(AssociationTestModelTwo)
    end

  end

  describe "related=" do

    before :each do
      @other = AssociationTestModelTwo.find "test_model_2"
    end

    it "should set the relation to nil" do
      @model.related_id = "test"
      @model.related = nil
      @model.related_id.should be_nil
    end

    it "should set the relation" do
      @model.related = @other
      @model.related_id.should == "test_model_2"
    end

    it "should raise an ArgumentError on wrong class" do
      lambda do
        @model.related = "test"
      end.should raise_error(ArgumentError)
    end

  end

end

describe AssociationTestModelTwo do

  before :each do
    @model = AssociationTestModelTwo.find "test_model_2"
  end

  describe "has_many" do

    it "should define the :related method" do
      @model.should respond_to(:related)
    end

  end

  describe "related" do

    before :each do
      @other = AssociationTestModelOne.find "test_model_1"
    end

    it "should return a collection" do
      @model.related.should be_instance_of(CouchModel::Collection)
    end

    it "should include the test model one" do
      @model.related.should include(@other)
      @model.related(@other.name).should include(@other)
    end

  end

end

require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "lib", "couch_model", "design"))

CouchModel::Configuration.design_directory = File.join File.dirname(__FILE__), "design"

describe CouchModel::Design do

  before :each do
    @model_class = Object
    @model_class.stub!(:to_s).and_return("BaseTestModel")
    @database = CouchModel::Database.new :name => "test"
    @design = CouchModel::Design.new @database, @model_class, :language => "another_language"
  end

  describe "initialize" do

    it "should set the database" do
      @design.database.should == @database
    end

    it "should set the model class" do
      @design.model_class.should == @model_class
    end

    it "should set the attributes" do
      @design.language.should == "another_language"
    end

  end

  describe "filename" do

    it "should return the name of the expected file" do
      @design.filename.should == File.join(CouchModel::Configuration.design_directory, "base_test_model.design")
    end

  end

  describe "load_file" do

    def do_load
      @design.load_file
    end

    context "file does exists" do

      it "should set the attributes" do
        do_load
        @design.id.should == "test_design"
        @design.language.should == "javascript"
        @design.views.should_not be_nil
      end
      
      it "should return true" do
        do_load.should be_true
      end

    end

    context "file doesn't exists" do

      before :each do
        @design.stub!(:filename).and_return("invalid")
      end

      it "should return false" do
        do_load.should be_false
      end

    end

  end

  describe "views=" do

    before :each do
      @view_hash = { "view_1" => { :map => "map function", :reduce => "reduce function" } }
    end

    it "should convert the given array of hashes into an array of views" do
      @design.views = @view_hash
      @design.views.first.should be_instance_of(CouchModel::View)
      @design.views.first.name.should == "view_1"
      @design.views.first.map.should == "map function"
      @design.views.first.reduce.should == "reduce function"
    end

  end

  describe "generate_view" do

    def do_generate
      @design.generate_view "test", :keys => [ :test ]
    end

    it "should return the view" do
      do_generate.should be_instance_of(CouchModel::View)
    end

    it "should add a generated view" do
      lambda do
        do_generate
      end.should change(@design.views, :size).by(1)
    end

  end

  describe "to_hash" do

    it "should return a hash with all the design data" do
      @design.to_hash.should == {
        "_id"       => "_design/test_design",
        "language"  => "another_language",
        "views"     => { "test_view" => {"map" => "function(document) { };", "reduce" => "function(key, values, rereduce) { };" } }
      }
    end
    
  end

  describe "exists?" do

    it "should return true is the design document exists" do
      @design.exists?.should be_true
    end

  end

  describe "push" do

    def do_push
      @design.push
    end

    it "should push the design" do
      do_push.should be_true
    end

  end

end

require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "lib", "couch_model", "design"))

describe CouchModel::Design do

  before :each do
    @database = CouchModel::Database.new :name => "frontera_test"
    @design = CouchModel::Design.from_file @database, File.join(File.dirname(__FILE__), "design", "base_test_model.design")
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
      @design.generate_view "test", "TestModel", :keys => [ :test ]
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
        "language"  => "javascript",
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

  describe "from_file" do

    it "should load the design from a file" do
      @design.id.should == "test_design"
      @design.views.first.should be_instance_of(CouchModel::View)
    end

  end

end

require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "lib", "couch_model", "database"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "lib", "couch_model", "design"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "lib", "couch_model", "view"))

describe CouchModel::View do

  before :each do
    @database = CouchModel::Database.new :name => "frontera_test"
    @design = CouchModel::Design.new @database, :id => "test"
    @view = CouchModel::View.new @design,
                                 :name    => "view name",
                                 :map     => "map function",
                                 :reduce  => "reduce function"
  end

  describe "initialize" do

    it "should set the name" do
      @view.name.should == "view name"
    end

    it "should set the map function" do
      @view.map.should == "map function"
    end

    it "should set the reduce function" do
      @view.reduce.should == "reduce function"
    end

  end

  describe "collection" do

    it "should return a collection" do
      @view.collection.should be_instance_of(CouchModel::Collection)
    end

    it "should initialize the collection with the view url" do
      @view.collection.url.should == @view.url
    end

    it "should pass the options to the collection" do
      @view.collection(:test => "test").options.should == { :test => "test" }
    end

  end

  describe "to_hash" do

    it "should return a hash with all view data" do
      @view.to_hash.should == {
        "view name" => {
          "map"     => "map function",
          "reduce"  => "reduce function"
        }
      }
    end

  end

  describe "generate_functions" do

    before :each do
      @class_name = "TestModel"
      @options    = { }
    end

    def do_generate
      @view.generate_functions @class_name, @options
    end

    describe "without any keys given" do

      it "should set the map function" do
        do_generate
        @view.map.should ==
"""function(document) {
  if (document['#{CouchModel::Configuration::CLASS_KEY}'] == '#{@class_name}') {
    emit(document['_id'], null);
  }
}
"""
      end

      it "should set the reduce function to nil" do
        do_generate
        @view.reduce.should be_nil
      end

    end

    describe "with keys given" do

      before :each do
        @options.merge! :keys => [ :foo, :bar ]
      end

      it "should set the map function" do
        do_generate
        @view.map.should ==
"""function(document) {
  if (document['#{CouchModel::Configuration::CLASS_KEY}'] == '#{@class_name}' && document['foo'] && document['bar']) {
    emit([ document['foo'], document['bar'] ], null);
  }
}
"""
      end
  
      it "should set the reduce function to nil" do
        do_generate
        @view.reduce.should be_nil
      end

    end

  end

end

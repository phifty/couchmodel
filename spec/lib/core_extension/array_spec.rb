require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "lib", "core_extension", "array"))

describe Array do

  describe "wrap" do

    it "should wrap an object into an array" do
      Array.wrap("test").should == [ "test" ]
    end

    it "should keep an array as it is" do
      Array.wrap([ "test" ]).should == [ "test" ]
    end

    it "should use to_ary to convert the object" do
      object = Object.new
      object.stub!(:to_ary).and_return([ "test" ])
      Array.wrap(object).should == [ "test" ]
    end

  end

end

require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "lib", "core_extension", "array"))

describe Array do

  describe "resize" do

    it "should extend an array to the given length with the given elements" do
      [ 1, 2, 3 ].resize(6, 4).should == [ 1, 2, 3, 4, 4, 4 ]
    end

    it "should shrink the array to the given length" do
      [ 1, 2, 3 ].resize(1).should == [ 1 ]
    end

    it "should return the original array if the given length fits" do
      [ 1, 2, 3 ].resize(3).should == [ 1, 2, 3 ]
    end

    it "should not change the original array" do
      array = [ 1, 2, 3 ]
      lambda do
        array.resize 6
        array.resize 1
      end.should_not change(array, :size)
    end

  end
  
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

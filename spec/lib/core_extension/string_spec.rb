require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "lib", "core_extension", "string"))

describe String do

  describe "underscore" do

    it "should convert camelcase to underscore" do
      "TestModel".underscore.should == "test_model"
    end

  end

  describe "camelize" do

    it "should convert underscore to camelcase" do
      "test_model".camelize.should == "TestModel"
    end

  end

end

require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "lib", "transport", "request", "builder"))

describe Transport::Request::Builder do

  before :each do
    @builder = Transport::Request::Builder.new :get,
                                               "http://localhost:5984/test",
                                               :headers    => { "Test-Header" => "test" },
                                               :parameters => { "test_parameter" => "test" }
  end

  describe "uri" do

    before :each do
      @uri = @builder.uri
    end

    it "should build an uri with the correct host, port and path" do
      @uri.host.should == "localhost"
      @uri.port.should == 5984
      @uri.path.should == "/test"
    end

  end

  describe "request" do

    before :each do
      @request = @builder.request
    end

    it "should have the correct class" do
      @request.should be_instance_of(Net::HTTP::Get)
    end

    it "should have the correct headers" do
      @request["Test-Header"].should == "test"
    end

    it "should point to the correct path" do
      @request.path.should == "/test?test_parameter=test"
    end

    it "should have the correct body" do
      @request.body.should be_nil
    end

  end

end

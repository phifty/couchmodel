require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "lib", "transport", "json"))

describe Transport::JSON do

  use_real_transport!

  describe "request" do

    before :each do
      @http_method = :get
      @url = "http://localhost:5984/"
      @options = {
        :auth_type            => :basic,
        :username             => "test",
        :password             => "test",
        :expected_status_code => 200
      }

      @request = Net::HTTP::Get.new "/", { }
      @response = Object.new
      @response.stub!(:code).and_return("200")
      @response.stub!(:body).and_return("{\"test\":\"test\"}")
      Net::HTTP.stub!(:start).and_return(@response)
    end

    def do_request(options = { })
      Transport::JSON.request @http_method, @url, @options.merge(options)
    end

    it "should initialize the correct request object" do
      Net::HTTP::Get.should_receive(:new).with("/", { "Accept" => "application/json" }).and_return(@request)
      do_request
    end

    it "should perform the request" do
      Net::HTTP.should_receive(:start).and_return(@response)
      do_request
    end

    it "should return the parsed response" do
      do_request.should == { "test" => "test" }
    end

    it "should raise NotImplementedError if the given auth_type is wrong" do
      lambda do
        do_request :auth_type => :invalid
      end.should raise_error(NotImplementedError)
    end

  end

end
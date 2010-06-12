require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "lib", "transport", "base"))

describe Transport::Base do

  use_real_transport!

  describe "request" do

    before :each do
      @http_method = :get
      @url = "http://localhost:5984/"
      @options = { }

      @request_builder = Transport::Request::Builder.new @http_method, @url, @options

      @response = Object.new
      @response.stub!(:code).and_return("200")
      @response.stub!(:body).and_return("test")
      Net::HTTP.stub!(:start).and_return(@response)
    end

    def do_request(options = { })
      Transport::Base.request @http_method, @url, @options.merge(options)
    end

    it "should initialize the correct request builder" do
      Transport::Request::Builder.should_receive(:new).with(@http_method, @url, @options).and_return(@request_builder)
      do_request
    end

    it "should perform the request" do
      Net::HTTP.should_receive(:start).and_return(@response)
      do_request
    end

    it "should return the response" do
      do_request.body.should == "test"
    end

    it "should raise UnexpectedStatusCodeError if responded status code is wrong" do
      lambda do
        do_request :expected_status_code => 201
      end.should raise_error(Transport::UnexpectedStatusCodeError)
    end

  end

end

require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "lib", "couch_model", "transport"))

describe CouchModel::Transport do

  describe "request" do

    use_real_transport!

    before :each do
      @http_method = :get
      @url = "http://localhost:5984/"
      @options = { }

      @request = Net::HTTP::Get.new "/"
      @response = Object.new
      @response.stub!(:code).and_return("200")
      @response.stub!(:body).and_return("{\"couchdb\":\"Welcome\",\"version\":\"0.10.0\"}")
      Net::HTTP.stub!(:start).and_return(@response)
    end

    def do_request(options = { })
      CouchModel::Transport.request @http_method, @url, @options.merge(options)
    end

    it "should initialize the correct request object" do
      Net::HTTP::Get.should_receive(:new).with("/").and_return(@request)
      do_request
    end

    it "should perform the request" do
      Net::HTTP.should_receive(:start).and_return(@response)
      do_request
    end

    it "should raise UnexpectedStatusCodeError if an unexpected status id returned" do
      lambda do
        do_request :expected_status_code => 201
      end.should raise_error(CouchModel::Transport::UnexpectedStatusCodeError)
    end

  end

  describe "serialize_parameters" do

    before :each do
      @parameters = { :test => [ :test, 1, 2, 3 ], :another_test => :test }
    end

    it "should return an empty string on empty parameter hash" do
      CouchModel::Transport.send(:serialize_parameters, { }).should == ""
    end
    
    it "should serialize the given parameters" do
      CouchModel::Transport.send(:serialize_parameters, @parameters).should ==
        "?another_test=test&test=[%22test%22,1,2,3]"
    end

  end

end

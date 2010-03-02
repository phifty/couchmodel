require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "lib", "couch_model", "server"))

describe CouchModel::Server do

  before :each do
    @server = CouchModel::Server.new
  end

  describe "==" do

    it "should be true when comparing two equal servers" do
      other = CouchModel::Server.new
      @server.should == other
    end

    it "should be false when comparing two different servers" do
      other = CouchModel::Server.new :host => "other"
      @server.should_not == other
    end
    
  end

  describe "informations" do

    it "should return server informations" do
      informations = @server.informations
      informations.should == {
        "couchdb" => "Welcome",
        "version" => "0.10.0"
      }
    end

  end

  describe "statistics" do

    it "should return server statistics" do
      statistics = @server.statistics
      statistics.should have_key("httpd_status_codes")
      statistics.should have_key("httpd_request_methods")
    end

  end

  describe "database_names" do

    it "should return the names of all databases" do
      database_names = @server.database_names
      database_names.should == [ "development", "test" ]
    end

  end

  describe "uuids" do

    it "should return a given number of uuids" do
      uuids = @server.uuids 3
      uuids.size.should == 3
    end

  end

end

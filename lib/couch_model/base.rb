require File.expand_path(File.join(File.dirname(__FILE__), "..", "core_extension", "string"))
require File.join(File.dirname(__FILE__), "configuration")
require File.join(File.dirname(__FILE__), "transport")
require File.join(File.dirname(__FILE__), "server")
require File.join(File.dirname(__FILE__), "database")
require File.join(File.dirname(__FILE__), "design")
require File.join(File.dirname(__FILE__), "core", "setup")
require File.join(File.dirname(__FILE__), "core", "accessor")
require File.join(File.dirname(__FILE__), "core", "finder")
require File.join(File.dirname(__FILE__), "core", "association")
require 'uri'

module CouchModel

  class Base
    include CouchModel::Core::Setup
    include CouchModel::Core::Accessor
    include CouchModel::Core::Finder
    include CouchModel::Core::Association

    class Error < StandardError; end
    class NotFoundError < StandardError; end

    attr_reader :attributes

    def initialize(attributes = { })
      @attributes = { Configuration::CLASS_KEY => self.class.to_s }
      self.attributes = attributes
    end

    def attributes=(attributes)
      attributes.each { |key, value| self.send :"#{key}=", value if self.respond_to?(:"#{key}=") }
    end

    def id
      @attributes["_id"]
    end
    alias :_id :id

    def id=(value)
      @attributes["_id"] = value
    end

    def rev
      @attributes["_rev"]
    end
    alias :_rev :rev

    def ==(other)
      self.id == other.id
    end

    def new?
      self.rev.nil?
    end

    def load
      response = Transport.request :get, url, :expected_status_code => 200

      self.rev = response["_rev"]
      [ "_id", "_rev", Configuration::CLASS_KEY ].each { |key| response.delete key }
      self.attributes = response
      true
    rescue Transport::UnexpectedStatusCodeError => e
      raise NotFoundError if e.status_code == 404
      raise e
    end

    def save
      new? ? create : update
    end

    def destroy
      return false if new?
      Transport.request :delete, self.url, :parameters => { "rev" => self.rev }, :expected_status_code => 200
      self.rev = nil
      true
    rescue Transport::UnexpectedStatusCodeError => e
      raise NotFoundError if e.status_code == 404
      raise e
    end

    def url
      "#{self.database.url}/#{self.id}"
    end

    def method_missing(method_name, *arguments, &block)
      return @attributes[Configuration::CLASS_KEY] if Configuration::CLASS_KEY == method_name.to_s
      super
    end

    private

    def rev=(value)
      @attributes["_rev"] = value      
    end

    def create
      response = Transport.request :post, self.database.url, :json => self.attributes, :expected_status_code => 201
      self.id  = response["id"]
      self.rev = response["rev"]
      true
    rescue Transport::UnexpectedStatusCodeError
      false
    end

    def update
      response = Transport.request :put, self.url, :json => self.attributes, :expected_status_code => 200
      self.rev = response["rev"]
      true
    rescue Transport::UnexpectedStatusCodeError
      false
    end

  end

end
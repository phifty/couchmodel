require File.expand_path(File.join(File.dirname(__FILE__), "..", "core_extension", "string"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "transport", "json"))
require File.join(File.dirname(__FILE__), "configuration")
require File.join(File.dirname(__FILE__), "server")
require File.join(File.dirname(__FILE__), "database")
require File.join(File.dirname(__FILE__), "design")
require File.join(File.dirname(__FILE__), "base", "setup")
require File.join(File.dirname(__FILE__), "base", "accessor")
require File.join(File.dirname(__FILE__), "base", "finder")
require File.join(File.dirname(__FILE__), "base", "association")
require 'uri'

module CouchModel

  # Base is the main super class of all models that should be stored in CouchDB.
  # See the README file for more informations.
  class Base
    include CouchModel::Base::Setup
    include CouchModel::Base::Accessor
    include CouchModel::Base::Finder
    include CouchModel::Base::Association

    # The NotFoundError will be raised if an operation is tried on a document that
    # dosen't exists.
    class NotFoundError < StandardError; end

    def attributes
      @attributes || {}
    end

    def initialize(attributes = { })
      klass = self.class
      @attributes = { Configuration::CLASS_KEY => klass.to_s }
      self.attributes = attributes

      klass.key_definitions.each do |key, definition|
        @attributes[key] = definition[:default] if definition.has_key?(:default) && !@attributes.has_key?(key)
      end
    end

    def attributes=(attributes)
      attributes = merge_multiparameter_attributes attributes
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
      load_response Transport::JSON.request(:get, url, :expected_status_code => 200)
      true
    rescue Transport::UnexpectedStatusCodeError => error
      upgrade_unexpected_status_error error
    end

    alias reload load

    def save
      new? ? create : update
    end

    def destroy
      return false if new?
      Transport::JSON.request :delete, self.url, :headers => { "If-Match" => self.rev }, :expected_status_code => 200
      clear_rev
      true
    rescue Transport::UnexpectedStatusCodeError => error
      upgrade_unexpected_status_error error
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

    def load_response(response)
      self.rev = response["_rev"]
      self.attributes = response
    end

    def create
      response = Transport::JSON.request :post, self.database.url, :body => self.attributes, :expected_status_code => 201
      self.id  = response["id"]
      self.rev = response["rev"]
      true
    rescue Transport::UnexpectedStatusCodeError
      false
    end

    def update
      response = Transport::JSON.request :put, self.url, :body => self.attributes, :expected_status_code => 201
      self.rev = response["rev"]
      true
    rescue Transport::UnexpectedStatusCodeError
      false
    end

    def clear_rev
      self.rev = nil
    end

    def upgrade_unexpected_status_error(error)
      raise NotFoundError if error.status_code == 404
      raise error
    end

    def self.create(*arguments)
      model = new *arguments
      model.save ? model : nil
    end

    def self.destroy_all
      all.each do |model|
        model.destroy
      end
    end

  end

end

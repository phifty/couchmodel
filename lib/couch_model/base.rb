require File.expand_path(File.join(File.dirname(__FILE__), "..", "core_extension", "string"))
require File.join(File.dirname(__FILE__), "configuration")
require File.join(File.dirname(__FILE__), "transport")
require File.join(File.dirname(__FILE__), "server")
require File.join(File.dirname(__FILE__), "database")
require File.join(File.dirname(__FILE__), "design")
require 'uri'

module CouchModel

  class Base

    class Error < StandardError; end
    class NotFoundError < StandardError; end

    attr_reader :attributes

    def initialize(attributes = { })
      @attributes = { Configuration::CLASS_KEY => self.class.to_s }
      self.attributes = attributes
    end

    def database
      self.class.database
    end

    def attributes=(attributes)
      attributes.each { |key, value| self.send :"#{key}=", value }
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
      other.is_a?(Base) && self.id == other.id
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

    class << self

      def setup_database(options = { })
        initialize_database options
        initialize_design
        generate_class_view
        define_view_methods
        push_design options
      end

      def key_reader(key)
        define_method :"#{key}" do
          @attributes[key.to_s]
        end
      end

      def key_writer(key)
        define_method :"#{key}=" do |value|
          @attributes[key.to_s] = value
        end
      end

      def key_accessor(key)
        key_reader key
        key_writer key
      end

      def database
        @database || raise(StandardError, "no database defined!")
      end

      def design
        @design
      end

      def find(id)
        document = new :id => id
        document.load
        document
      end

      private

      def initialize_database(options)
        url                     = options[:url] || raise(ArgumentError, "no url was given to define the database")
        setup_on_initialization = options[:setup_on_initialization] || false
        
        uri = URI.parse url
        server = Server.new :host => uri.host, :port => uri.port
        database = Database.new :server => server, :name => uri.path.gsub("/", "")
        @database = Configuration.register_database database

        @database.setup! options if setup_on_initialization && @database === database
      end

      def initialize_design
        filename = File.join Configuration.design_directory, "#{self.to_s.underscore}.design"
        @design = File.exists?(filename) ? Design.from_file(@database, filename) : Design.new(@database, :id => self.to_s.underscore)
        Configuration.register_design @design
      end

      def generate_class_view
        @design.generate_view Configuration::CLASS_VIEW_NAME, self.to_s
      end

      def define_view_methods
        @design.views.each do |view|
          self.class.class_eval do
            define_method view.name do |*arguments|
              view.collection *arguments
            end
          end
        end
      end

      def push_design(options)
        setup_on_initialization = options[:setup_on_initialization] || false
        @design.push if setup_on_initialization
      end

    end

  end

end
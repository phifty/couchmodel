require File.expand_path(File.join(File.dirname(__FILE__), "..", "transport", "json"))
require File.join(File.dirname(__FILE__), "server")
require File.join(File.dirname(__FILE__), "collection")

module CouchModel

  # The Database class provides methods create, delete and retrieve informations
  # of a CouchDB database.
  class Database

    attr_reader :server
    attr_reader :name

    def initialize(options = { })
      @name   = options[:name]    || raise(ArgumentError, "no database was given")
      @server = options[:server]  || Server.new
    end

    def ==(other)
      other.is_a?(self.class) && @name == other.name && @server == other.server
    end

    def ===(other)
      object_id == other.object_id
    end

    def create!
      Transport::JSON.request :put, url, :expected_status_code => 201
    end

    def create_if_missing!
      create! unless exists?
    end

    def delete!
      Transport::JSON.request :delete, url, :expected_status_code => 200
    end

    def delete_if_exists!
      delete! if exists?
    end

    def informations
      Transport::JSON.request :get, url, :expected_status_code => 200
    end

    def exists?
      @server.database_names.include? @name
    end

    def url
      "#{@server.url}/#{@name}"
    end

    def documents(options = { })
      Collection.new url + "/_all_docs", options
    end

  end

end

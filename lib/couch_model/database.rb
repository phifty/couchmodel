require File.join(File.dirname(__FILE__), "transport")
require File.join(File.dirname(__FILE__), "server")
require File.join(File.dirname(__FILE__), "collection")

module CouchModel

  class Database

    class Error < StandardError; end

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
      Transport.request :put, url, :expected_status_code => 201
    end

    def create_if_missing!
      create! unless exists?
    end

    def delete!
      Transport.request :delete, url, :expected_status_code => 200
    end

    def delete_if_exists!
      delete! if exists?
    end

    def informations
      Transport.request :get, url, :expected_status_code => 200
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

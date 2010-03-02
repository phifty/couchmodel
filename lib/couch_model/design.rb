require File.join(File.dirname(__FILE__), "transport")
require File.join(File.dirname(__FILE__), "base")
require File.join(File.dirname(__FILE__), "view")
require 'yaml'

module CouchModel

  class Design

    attr_reader   :database
    attr_accessor :id
    attr_reader   :rev
    attr_accessor :language
    attr_reader   :views

    def initialize(database, attributes = { })
      @database     = database
      self.id       = attributes[:id]
      self.language = attributes[:language] || "javascript"
      self.views    = attributes[:views]
    end

    def views=(view_hash)
      @views = [ ]
      view_hash.each do |view_name, view|
        @views << View.new(self, view.merge(:name => view_name)) if view.is_a?(Hash)
      end if view_hash.is_a?(Hash)
    end

    def generate_view(name, class_name, options = { })
      view = View.new self, :name => name
      view.generate_functions class_name, options
      @views.insert 0, view
      view
    end

    def to_hash
      hash = {
        "_id"       => "_design/#{self.id}",
        "language"  => self.language,
        "views"     => { }
      }
      hash.merge! "_rev" => self.rev if self.rev
      @views.each { |view| hash["views"].merge! view.to_hash }
      hash
    end

    def exists?
      Transport.request :get, self.url, :expected_status_code => 200
      true
    rescue Transport::UnexpectedStatusCodeError
      false
    end

    def push
      response = Transport.request :get, self.url
      self.rev = response["_rev"] if response["_rev"]

      Transport.request :put, self.url, :json => self.to_hash, :expected_status_code => 201
      true
    end

    def url
      "#{@database.url}/_design/#{self.id}"
    end

    private

    attr_writer :rev

    class << self

      def from_file(database, filename)
        new database, YAML::load_file(filename)
      end

    end

  end

end

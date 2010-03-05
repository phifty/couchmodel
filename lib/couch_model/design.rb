require File.join(File.dirname(__FILE__), "configuration")
require File.join(File.dirname(__FILE__), "transport")
require File.join(File.dirname(__FILE__), "base")
require File.join(File.dirname(__FILE__), "view")
require 'yaml'

module CouchModel

  class Design

    attr_reader   :database
    attr_reader   :model_class
    attr_accessor :id
    attr_reader   :rev
    attr_accessor :language
    attr_reader   :views

    def initialize(database, model_class, attributes = { })
      @database     = database
      @model_class  = model_class
      @language     = "javascript"
      @views        = [ ]

      load_file
      self.id       = attributes[:id]       if attributes[:id]
      self.language = attributes[:language] if attributes[:language]
      self.views    = attributes[:views]    if attributes[:views]
    end

    def filename
      @filename ||= File.join(CouchModel::Configuration.design_directory, "#{model_class.to_s.underscore}.design")
    end

    def load_file
      return false unless File.exists?(filename)
      attributes = YAML::load_file filename
      self.id       = attributes[:id]
      self.language = attributes[:language]
      self.views    = attributes[:views]
      true
    end

    def views=(view_hash)
      @views = [ ]
      view_hash.each do |view_name, view|
        @views << View.new(self, view.merge(:name => view_name)) if view.is_a?(Hash)
      end if view_hash.is_a?(Hash)
    end

    def generate_view(name, options = { })
      view = View.new self, options.merge(:name => name)
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

  end

end

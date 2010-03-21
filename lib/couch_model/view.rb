require File.join(File.dirname(__FILE__), "configuration")
require File.join(File.dirname(__FILE__), "collection")

module CouchModel

  # The View class acts as a wrapper for the views that are in the CouchDB design document. It also
  # provides methods to generate simple view javascript functions.
  class View

    attr_reader   :design
    attr_accessor :name
    attr_accessor :map
    attr_accessor :reduce

    def initialize(design, attributes = { })
      @design = design
      @name   = attributes[:name]

      generate_functions attributes
      @map    = attributes[:map]    if attributes.has_key?(:map)
      @reduce = attributes[:reduce] if attributes.has_key?(:reduce)
    end

    def collection(options = { })
      Collection.new url, options
    end

    def to_hash
      { self.name => { "map" => self.map, "reduce" => self.reduce } }
    end

    def url
      "#{@design.url}/_view/#{@name}"
    end

    def generate_functions(options = { })
      keys = [ (options[:keys] || "_id") ].flatten
      @map = self.class.generate_map_function @design.model_class, keys
      @reduce = nil
    end

    def self.generate_map_function(model_class, keys)
      emit_values  = keys.map{ |key| "document['#{key}']" }
      check_values = emit_values.select{ |value| value != "document['_id']" }

"""function(document) {
  if (document['#{Configuration::CLASS_KEY}'] == '#{model_class.to_s}'#{check_values.empty? ? "" : " && " + check_values.join(" && ")}) {
    emit(#{emit_values.size == 1 ? emit_values.first : "[ " + emit_values.join(", ") + " ]"}, null);
  }
}
"""
    end

  end

end
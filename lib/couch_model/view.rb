require File.join(File.dirname(__FILE__), "configuration")
require File.join(File.dirname(__FILE__), "collection")

module CouchModel

  class View

    attr_reader   :design
    attr_accessor :name
    attr_accessor :map
    attr_accessor :reduce

    def initialize(design, attributes = { })
      @design = design
      @name   = attributes[:name]
      @map    = attributes[:map]
      @reduce = attributes[:reduce]
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

    def generate_functions(class_name, options = { })
      keys = [ (options[:keys] || "_id") ].flatten

      emit_values  = keys.map{ |key| "document['#{key}']" }
      check_values = emit_values.select{ |value| value != "document['_id']" }

      @map =
"""function(document) {
  if (document['#{Configuration::CLASS_KEY}'] == '#{class_name}'#{check_values.empty? ? "" : " && " + check_values.join(" && ")}) {
    emit(#{emit_values.size == 1 ? emit_values.first : "[ " + emit_values.join(", ") + " ]"}, null);
  }
}
"""
      @reduce = nil
    end

  end

end
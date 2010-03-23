require File.join(File.dirname(__FILE__), "configuration")

module CouchModel

  # The Row class acts as a wrapper for a CouchDB view result row.
  class Row

    attr_reader :id
    attr_reader :key
    attr_reader :value
    attr_reader :document

    def initialize(attributes = { })
      @id, @key, @value, @document = attributes.values_at "id", "key", "value", "doc"
    end

    def model
      return nil unless @document && @document.has_key?(Configuration::CLASS_KEY)

      model_class_name = document[Configuration::CLASS_KEY]
      raise StandardError, "no class defined with name [#{model_class_name}]" unless Object.const_defined?(model_class_name)
      instanciate_model model_class_name
    end

    def instanciate_model(model_class_name)
      model_class = Object.const_get model_class_name
      model = model_class.new
      model.instance_variable_set :@attributes, @document
      model
    end
    
  end

end

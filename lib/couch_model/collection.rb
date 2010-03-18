require File.join(File.dirname(__FILE__), "configuration")
require File.join(File.dirname(__FILE__), "transport")
require 'json'

module CouchModel

  class Collection

    REQUEST_PARAMETER_KEYS = [
      :key, :startkey, :startkey_docid, :endkey, :endkey_docid,
      :limit, :stale, :descending, :skip, :group, :group_level,
      :reduce, :inclusive_end
    ].freeze unless defined?(REQUEST_PARAMETER_KEYS)

    ARRAY_METHOD_NAMES = [
      :[], :at, :collect, :compact, :count, :cycle, :each, :each_index,
      :empty?, :fetch, :index, :first, :flatten, :include?, :join, :last,
      :length, :map, :pack, :reject, :reverse, :reverse_each, :rindex,
      :sample, :shuffle, :size, :slice, :sort, :take, :to_a, :to_ary,
      :values_at, :zip
    ].freeze unless defined?(ARRAY_METHOD_NAMES)

    attr_reader :url
    attr_reader :options

    def initialize(url, options = { })
      @url, @options = url, options
    end

    def total_count
      fetch :meta => true unless @total_count
      @total_count
    end

    def respond_to?(method_name)
      ARRAY_METHOD_NAMES.include?(method_name) || super
    end

    def method_missing(method_name, *arguments, &block)
      if ARRAY_METHOD_NAMES.include?(method_name)
        fetch
        @entries.send method_name, *arguments, &block
      else
        super
      end
    end

    private

    def fetch(options = { })
      meta = options[:meta] || false

      evaluate Transport.request(
        :get, url,
        :parameters            => request_parameters.merge(meta ? { "limit" => "0" } : { }),
        :expected_status_code  => 200
      )
      
      true
    end

    def request_parameters
      parameters = { "include_docs" => "true" }
      REQUEST_PARAMETER_KEYS.each do |key|
        parameters[ key.to_s ] = @options[key].is_a?(Array) ? JSON.dump(@options[key]) : @options[key].to_s if @options[key]
      end
      parameters
    end
    
    def evaluate(response)
      @total_count = response["total_rows"]
      @entries = response["rows"].select do |row|
        row["doc"].has_key?(Configuration::CLASS_KEY) && Object.const_defined?(row["doc"][Configuration::CLASS_KEY])
      end.map &method(:map_row_to_model)
    end

    def map_row_to_model(row)
      model_class = Object.const_get row["doc"][Configuration::CLASS_KEY]
      model = model_class.new
      model.instance_variable_set :@attributes, row["doc"]
      model      
    end

  end

end
require File.expand_path(File.join(File.dirname(__FILE__), "..", "transport", "json"))
require File.join(File.dirname(__FILE__), "row")

module CouchModel

  # Collection is a proxy class for the resultset of a CouchDB view. It provides
  # all read-only methods of an array. The loading of content is lazy and
  # will be triggerd on the first request.
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
      @options[:returns] ||= :models
    end

    def total_count
      fetch_meta unless @total_count
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

    def fetch
      fetch_response
      evaluate_total_count
      evaluate_entries
      true
    end

    def fetch_meta
      fetch_meta_response
      evaluate_total_count
      true
    end

    def fetch_response
      @response = Transport::JSON.request(
        :get, url,
        :parameters            => request_parameters,
        :expected_status_code  => 200
      )
    end

    def fetch_meta_response
      @response = Transport::JSON.request(
        :get, url,
        :parameters            => request_parameters.merge(:limit => 0),
        :expected_status_code  => 200
      )
    end

    def request_parameters
      parameters = @options[:returns] == :models ? { :include_docs => true } : { }
      REQUEST_PARAMETER_KEYS.each do |key|
        parameters[ key ] = @options[key] if @options.has_key?(key)
      end
      parameters
    end

    def evaluate_total_count
      @total_count = @response["total_rows"]
    end
    
    def evaluate_entries
      returns = @options[:returns]
      @entries = @response["rows"].map do |row_hash|
        row = CouchModel::Row.new row_hash
        returns == :models ? row.model : row
      end
    end

  end

end
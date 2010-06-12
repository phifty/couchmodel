require File.join(File.dirname(__FILE__), "parameter", "serializer")

module Transport

  module Request

    # Builder for the transport layer requests
    class Builder

      HTTP_METHODS_WITH_PARAMETERS = [ :get, :delete ].freeze unless defined?(HTTP_METHODS_WITH_PARAMETERS)
      HTTP_METHODS_WITH_BODY       = [ :post, :put ].freeze unless defined?(HTTP_METHODS_WITH_BODY)

      def initialize(http_method, url, options = { })
        @http_method          = http_method
        @uri                  = URI.parse url
        @headers              = options[:headers] || { }
        @parameter_serializer = Parameter::Serializer.new options[:parameters]
        @body                 = options[:body]
      end

      def uri
        @uri
      end

      def request
        initialize_request_class
        initialize_request_path
        initialize_request
        initialize_request_body
        @request
      end

      private

      def initialize_request_class
        request_class_name = @http_method.to_s.capitalize
        raise NotImplementedError, "the request method #{http_method} is not implemented" unless Net::HTTP.const_defined?(request_class_name)
        @request_class = Net::HTTP.const_get request_class_name
      end

      def initialize_request_path
        query = HTTP_METHODS_WITH_PARAMETERS.include?(@http_method.to_sym) ? @parameter_serializer.query : nil
        @request_path = @uri.path + (query ? "?" + query : "")
      end

      def initialize_request
        @request = @request_class.new @request_path, @headers
      end

      def initialize_request_body
        return unless HTTP_METHODS_WITH_BODY.include?(@http_method.to_sym)
        @request.body = @body ? @body : @parameter_serializer.query
      end

    end

  end

end

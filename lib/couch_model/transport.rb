require 'uri'
require 'net/http'
require 'json'

module CouchModel

  module Transport

    class Error < StandardError; end

    class UnexpectedStatusCodeError < StandardError

      attr_reader :status_code

      def initialize(status_code)
        @status_code = status_code
      end

      def to_s
        "#{super} received status code #{self.status_code}"
      end

    end

    class << self

      def request(http_method, url, options = { })
        expected_status_code = options[:expected_status_code]
        
        uri = URI.parse @base_url ? @base_url + url : url

        request_class = request_class http_method
        request = request_object request_class, uri, options

        response = Net::HTTP.start(uri.host, uri.port) { |connection| connection.request request }

        raise UnexpectedStatusCodeError, response.code.to_i if expected_status_code && expected_status_code.to_s != response.code
        JSON.parse response.body
      end

      private

      def request_class(http_method)
        Net::HTTP.const_get http_method.capitalize
      end

      def request_object(request_class, uri, options)
        parameters  = options[:parameters] || { }
        json        = options[:json]

        case request_class.to_s
          when "Net::HTTP::Get", "Net::HTTP::Delete"
            request_class.new uri.path +
              (parameters.empty? ? "" : "?" + parameters.collect{ |key, value| "#{key}=#{URI.escape(value.to_s)}" }.reverse.join("&"))
          when "Net::HTTP::Post", "Net::HTTP::Put"
            request = request_class.new uri.path, { "Content-Type" => "application/json" }
            request.body = JSON.dump(json) if json
            request
          else
            request_class.new uri.path
        end
      end

    end
    
  end

end
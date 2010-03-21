require 'uri'
require 'net/http'
require 'json'

module CouchModel

  module Transport

    # The UnexpectedStatusCodeError is raised if the :expected_status_code option is given to
    # the :request method and the responded status code is different from the expected one.
    class UnexpectedStatusCodeError < StandardError

      attr_reader :status_code

      def initialize(status_code)
        @status_code = status_code
      end

      def to_s
        "#{super} received status code #{self.status_code}"
      end

    end

    def self.request(http_method, url, options = { })
      expected_status_code = options[:expected_status_code]

      uri = URI.parse url
      response = perform request_object(http_method, uri, options), uri

      check_status_code response, expected_status_code if expected_status_code
      parse response
    end

    def self.request_object(http_method, uri, options)
      raise NotImplementedError, "the request method #{http_method} is not implemented" unless
        self.respond_to?(:"#{http_method}_request_object")

      request_object = send :"#{http_method}_request_object", uri.path, (options[:parameters] || { })
      request_object.body = options[:body].to_json if options.has_key?(:body)
      request_object
    end

    def self.get_request_object(path, parameters)
      Net::HTTP::Get.new path + serialize_parameters(parameters)
    end

    def self.post_request_object(path, parameters)
      Net::HTTP::Post.new path, { "Content-Type" => "application/json" }
    end

    def self.put_request_object(path, parameters)
      Net::HTTP::Put.new path, { "Content-Type" => "application/json" }
    end

    def self.delete_request_object(path, parameters)
      Net::HTTP::Delete.new path + serialize_parameters(parameters)
    end

    def self.serialize_parameters(parameters)
      return "" if parameters.empty?
      "?" + parameters.collect do |key, value|
        value = value.is_a?(Array) ? value.to_json : value.to_s
        "#{key}=#{URI.escape(value)}"
      end.reverse.join("&")
    end

    def self.perform(request, uri)
      Net::HTTP.start(uri.host, uri.port) do |connection|
        connection.request request
      end
    end

    def self.check_status_code(response, expected_status_code)
      response_code = response.code
      raise UnexpectedStatusCodeError, response_code.to_i if expected_status_code.to_s != response_code
    end

    def self.parse(response)
      JSON.parse response.body
    end

  end

end

require 'json'
require File.join(File.dirname(__FILE__), "base")

module Transport

  # Extended transport layer for http transfers. Basic authorization and JSON transfers are supported.
  class JSON < Base

    attr_reader :expected_status_code
    attr_reader :auth_type
    attr_reader :username
    attr_reader :password

    def initialize(http_method, url, options = { })
      super http_method, url, options
      @auth_type = options[:auth_type]
      @username  = options[:username]
      @password  = options[:password]
    end

    def perform
      initialize_headers
      super
      parse_response
    end

    private

    def initialize_headers
      @headers["Accept"] = "application/json"
    end

    def initialize_request
      super
      if @auth_type == :basic
        @request.basic_auth @username, @password
      elsif @auth_type
        raise NotImplementedError, "the given auth_type [#{@auth_type}] is not implemented"
      end
    end

    def quote_parameters
      @parameters.each do |key, value|
        @parameters[key] = value.to_json if value.respond_to?(:to_json)
      end
      super
    end

    def initialize_request_body
      super
      if @body
        @request.body = @body.to_json
        @request["Content-Type"] = "application/json"
      end
    end

    def parse_response
      body = @response.body
      @response = body.nil? ? nil : ::JSON.parse(body)
    rescue ::JSON::ParserError
      @response = body.to_s
    end

  end

end

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
      @options = options
      modify_headers
      modify_parameters
      modify_body
      super http_method, url, @options
      initialize_authentication
    end

    def perform
      super
      parse_response
    end

    private

    def modify_headers
      headers = (@options[:headers] || { }).merge("Accept" => "application/json")
      headers.merge! "Content-Type" => "application/json" if @options[:body]
      @options[:headers] = headers
    end

    def modify_parameters
      parameters = @options[:parameters]
      if parameters
        parameters.each do |key, value|
          parameters[key] = value.to_json if value.respond_to?(:to_json)
        end
        @options[:parameters] = parameters
      end
    end

    def modify_body
      body = @options[:body]
      @options[:body] = body.to_json if body
    end

    def initialize_authentication
      auth_type = @options[:auth_type]
      if auth_type == :basic
        @request.basic_auth @options[:username], @options[:password]
      elsif auth_type
        raise NotImplementedError, "the given auth_type [#{auth_type}] is not implemented"
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

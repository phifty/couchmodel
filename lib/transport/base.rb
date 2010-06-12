require File.join(File.dirname(__FILE__), "request", "builder")
require 'uri'
require 'net/http'

module Transport

  # Common transport layer for http transfers.
  class Base

    attr_reader :http_method
    attr_reader :url
    attr_reader :options
    attr_reader :headers
    attr_reader :parameters
    attr_reader :body
    attr_reader :response

    def initialize(http_method, url, options = { })
      @request_builder = Request::Builder.new http_method, url, options
      @uri             = @request_builder.uri
      @request         = @request_builder.request

      @expected_status_code = options[:expected_status_code]
    end

    def perform
      perform_request
      check_status_code
    end

    def self.request(http_method, url, options = { })
      transport = new http_method, url, options
      transport.perform
      transport.response
    end

    private

    def perform_request
      @response = Net::HTTP.start(@uri.host, @uri.port) do |connection|
        connection.request @request
      end
    end

    def check_status_code
      return unless @expected_status_code
      response_code = @response.code
      response_body = @response.body
      raise UnexpectedStatusCodeError.new(response_code.to_i, response_body) if @expected_status_code.to_s != response_code
    end

  end

  # The UnexpectedStatusCodeError is raised if the :expected_status_code option is given to
  # the :request method and the responded status code is different from the expected one.
  class UnexpectedStatusCodeError < StandardError

    attr_reader :status_code
    attr_reader :message

    def initialize(status_code, message = nil)
      @status_code, @message = status_code, message
    end

    def to_s
      "#{super} received status code #{self.status_code}" + (@message ? " [#{@message}]" : "")
    end

  end

end

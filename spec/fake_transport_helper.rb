require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "transport", "json"))
require 'yaml'

module FakeTransport

  def self.enable!
    @enabled = true
  end

  def self.disable!
    @enabled = false
  end

  def self.transport_class
    Transport::JSON
  end

  def self.unexpected_status_code_error_class
    Transport::UnexpectedStatusCodeError
  end

  def self.fake!
    return unless @enabled
    @@fake ||= YAML::load_file File.join(File.dirname(__FILE__), "fake_transport.yml")
    transport_class.stub!(:request).and_return do |http_method, url, options|
      options ||= { }
      parameters            = options[:parameters]
      headers               = options[:headers]
      expected_status_code  = options[:expected_status_code]

      request = @@fake.detect do |hash|
        hash[:http_method].to_s == http_method.to_s &&
          hash[:url].to_s == url.to_s &&
          hash[:parameters] == parameters &&
          hash[:headers] == headers
      end
      raise StandardError, "no fake request found for [#{http_method} #{url} #{parameters.inspect} #{headers.inspect}]" unless request
      raise unexpected_status_code_error_class.new(request[:response][:code].to_i, request[:response][:body]) if expected_status_code && expected_status_code.to_s != request[:response][:code]
      request[:response][:body].dup
    end
  end

end

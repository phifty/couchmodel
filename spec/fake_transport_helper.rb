require 'yaml'

module CouchModel

  module Transport

    def self.fake!
      @@fake ||= YAML::load_file File.join(File.dirname(__FILE__), "fake_transport.yml")
      self.stub!(:request).and_return do |http_method, url, options|
        options ||= { }
        parameters            = options[:parameters]
        expected_status_code  = options[:expected_status_code]

        request = @@fake.detect do |hash|
          hash[:http_method].to_s == http_method.to_s &&
            hash[:url].to_s == url.to_s &&
            hash[:parameters] == parameters
        end
        raise StandardError, "no fake request found for [#{http_method} #{url} #{parameters.inspect}]" unless request
        raise UnexpectedStatusCodeError, request[:response][:code].to_i if expected_status_code && expected_status_code.to_s != request[:response][:code]
        request[:response][:body].dup
      end
    end

  end

end

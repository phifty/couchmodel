require 'cgi'

module Transport

  module Request

    module Parameter

      # Serializer for transport http parameters
      class Serializer

        def initialize(parameters = nil)
          @parameters = parameters || { }
        end

        def query
          return @serialized_parameters if @serialized_parameters

          serialize_parameters
          @serialized_parameters
        end

        private

        def serialize_parameters
          quote_parameters
          @serialized_parameters = if @parameters.nil? || @parameters.empty?
            nil
          else
            @quoted_parameters.collect do |key, value|
              self.class.pair key, value
            end.join("&")
          end
        end

        def quote_parameters
          @quoted_parameters = { }
          @parameters.each do |key, value|
            encoded_key = CGI.escape(key.to_s)
            @quoted_parameters[encoded_key] = self.class.escape value
          end
        end

        def self.pair(key, value)
          value.is_a?(Array) ?
            value.map{ |element| "#{key}=#{element}" }.join("&") :
            "#{key}=#{value}"
        end

        def self.escape(value)
          value.is_a?(Array) ? value.map{ |element| CGI.escape element } : CGI.escape(value)
        end

      end

    end

  end

end

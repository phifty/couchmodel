
module CouchModel

  # This should extend the Base class to provide key_accessor methods.
  class Base

    module Accessor

      def self.included(base_class)
        base_class.class_eval do
          extend ClassMethods
        end
      end

      module ClassMethods

        def key_reader(key, options = { })
          raise ArgumentError, "method #{key} is already defined" if method_defined?(:"#{key}")
          set_default key, options[:default] if options.has_key?(:default)
          define_method :"#{key}" do
            @attributes[key.to_s]
          end
        end

        def key_writer(key, options = { })
          raise ArgumentError, "method #{key}= is already defined" if method_defined?(:"#{key}=")
          set_default key, options[:default] if options.has_key?(:default)
          define_method :"#{key}=" do |value|
            @attributes[key.to_s] = value
          end
        end

        def key_accessor(*arguments)
          key_reader *arguments
          key_writer *arguments
        end

      end

    end

  end

end

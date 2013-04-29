require 'time'

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

        attr_reader :key_definitions

        def key_reader(key, options = { })
          set_key_definition key, options
          type = options[:type] || :string
          send :"define_#{type}_reader", key
        rescue NoMethodError
          raise ArgumentError, "type #{type} isn't supported"
        end

        def key_writer(key, options = { })
          set_key_definition key, options
          type = options[:type] || :string
          send :"define_#{type}_writer", key
        rescue NoMethodError
          raise ArgumentError, "type #{type} isn't supported"
        end

        def key_accessor(*arguments)
          key_reader *arguments
          key_writer *arguments
        end

        private

        def set_key_definition(key, definition)
          @key_definitions ||= { }
          @key_definitions[key.to_s] = definition
        end

        def define_integer_reader(name)
          define_method :"#{name}" do
            @attributes[name.to_s].to_i
          end
        end

        def define_integer_writer(name)
          define_method :"#{name}=" do |value|
            @attributes[name.to_s] = value.to_i
          end
        end

        def define_string_reader(name)
          define_method :"#{name}" do
            @attributes[name.to_s]
          end
        end

        def define_string_writer(name)
          define_method :"#{name}=" do |value|
            @attributes[name.to_s] = value
          end
        end

        def define_date_reader(name)
          define_method :"#{name}" do
            value = @attributes[name.to_s]
            value ? Date.parse(value) : nil
          end
        end

        def define_date_writer(name)
          define_method :"#{name}=" do |value|
            @attributes[name.to_s] = value ? value.to_s : nil
          end
        end

        def define_time_reader(name)
          define_method :"#{name}" do
            value = @attributes[name.to_s]
            value ? Time.parse(value) : nil
          end
        end

        def define_time_writer(name)
          define_method :"#{name}=" do |value|
            @attributes[name.to_s] = value.is_a?(Time) ? value.strftime("%Y-%m-%d %H:%M:%S %z") : value
          end
        end

      end

    end

  end

end

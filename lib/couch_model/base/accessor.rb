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

        def key_reader(key, options = { })
          raise ArgumentError, "method #{key} is already defined" if method_defined?(:"#{key}")
          default, type = options.values_at :default, :type
          set_default key, default if default
          send :"define_#{type || :string}_reader", key
        rescue NoMethodError
          raise ArgumentError, "type #{type} isn't supported"
        end

        def key_writer(key, options = { })
          raise ArgumentError, "method #{key}= is already defined" if method_defined?(:"#{key}=")
          default, type = options.values_at :default, :type
          set_default key, default if default
          send :"define_#{type || :string}_writer", key
        rescue NoMethodError
          raise ArgumentError, "type #{type} isn't supported"
        end

        def key_accessor(*arguments)
          key_reader *arguments
          key_writer *arguments
        end

        private

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
            Date.parse @attributes[name.to_s]
          end
        end

        def define_date_writer(name)
          define_method :"#{name}=" do |value|
            @attributes[name.to_s] = value.to_s
          end
        end

        def define_time_reader(name)
          define_method :"#{name}" do
            Time.parse @attributes[name.to_s]
          end
        end

        def define_time_writer(name)
          define_method :"#{name}=" do |value|
            @attributes[name.to_s] = value.strftime("%Y-%m-%d %H:%M:%S %z")
          end
        end

      end

    end

  end

end

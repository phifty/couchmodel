
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

        def key_reader(key)
          define_method :"#{key}" do
            @attributes[key.to_s]
          end
        end

        def key_writer(key)
          define_method :"#{key}=" do |value|
            @attributes[key.to_s] = value
          end
        end

        def key_accessor(key)
          key_reader key
          key_writer key
        end

      end

    end

  end

end

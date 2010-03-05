
module CouchModel

  module Core

    module Association

      def self.included(base_class)
        base_class.class_eval do
          extend ClassMethods
        end
      end

      module ClassMethods

        def belongs_to(name, options = { })
          class_name  = options[:class_name]  || name.to_s.camelize
          key         = options[:key]         || "#{name}_id"
          klass = Object.const_get class_name

          key_accessor key

          define_method :"#{name}" do
            klass.find self.send(key)
          end

          define_method :"#{name}=" do |value|
            if value
              raise ArgumentError, "only objects of class #{klass} are accepted" unless value.is_a?(klass)
              self.send :"#{key}=", value.id
            else
              self.send :"#{key}=", nil
            end
          end
        end

      end

    end

  end

end

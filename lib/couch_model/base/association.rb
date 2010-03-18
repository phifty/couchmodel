
module CouchModel

  class Base

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

          key_accessor key
          define_belongs_to_reader name, class_name, key
          define_belongs_to_writer name, class_name, key
        end

        def has_many(name, options = { })
          class_name  = options[:class_name]  || name.to_s.camelize
          view_name   = options[:view_name]   || raise(ArgumentError, "no view_name is given")
          query       = options[:query]

          define_has_many_query name, query
          define_has_many_reader name, class_name, view_name
        end

        private

        def define_belongs_to_reader(name, class_name, key)
          define_method :"#{name}" do
            klass = Object.const_get class_name
            klass.find self.send(key)
          end          
        end

        def define_belongs_to_writer(name, class_name, key)
          define_method :"#{name}=" do |value|
            klass = Object.const_get class_name
            if value
              raise ArgumentError, "only objects of class #{klass} are accepted" unless value.is_a?(klass)
              self.send :"#{key}=", value.id
            else
              self.send :"#{key}=", nil
            end
          end
        end

        def define_has_many_query(name, query)
          define_method :"#{name}_query", &query if query.is_a?(Proc)
        end

        def define_has_many_reader(name, class_name, view_name)
          define_method :"#{name}" do |*arguments|
            klass = Object.const_get class_name
            query = if self.respond_to?(:"#{name}_query")
              arguments << nil while arguments.length < self.method(:"#{name}_query").arity
              self.send :"#{name}_query", *arguments
            else
              { :key => "\"#{self.id}\"" }
            end
            klass.send :"#{view_name}", query
          end
        end

      end

    end

  end

end

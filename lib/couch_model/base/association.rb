
module CouchModel

  # This should extend the Base class to provide association methods.
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

        def define_belongs_to_reader(reader_name, class_name, key)
          define_method :"#{reader_name}" do
            klass = Object.const_get class_name
            klass.find self.send(key)
          end          
        end

        def define_belongs_to_writer(writer_name, class_name, key)
          define_method :"#{writer_name}=" do |value|
            klass = Object.const_get class_name
            if value
              raise ArgumentError, "only objects of class #{klass} are accepted" unless value.is_a?(klass)
              self.send :"#{key}=", value.id
            else
              self.send :"#{key}=", nil
            end
          end
        end

        def define_has_many_query(query_name, query)
          define_method :"#{query_name}_query", &query if query.is_a?(Proc)
        end

        def define_has_many_reader(reader_name, class_name, view_name)
          define_method :"#{reader_name}" do |*arguments|
            query = if self.respond_to?(:"#{reader_name}_query")
              arguments << nil while arguments.length < self.method(:"#{reader_name}_query").arity
              self.send :"#{reader_name}_query", *arguments
            else
              { :key => "\"#{self.id}\"" }
            end
            Object.const_get(class_name).send :"#{view_name}", query
          end
        end

      end

    end

  end

end

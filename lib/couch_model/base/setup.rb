
module CouchModel

  class Base # :nodoc:

    module Setup

      def self.included(base_class)
        base_class.class_eval do
          include InstanceMethods
          extend ClassMethods
        end
      end

      module InstanceMethods

        def database
          self.class.database
        end
        
      end

      module ClassMethods

        def setup_database(options = { })
          initialize_database options
          initialize_design
          generate_class_view
          push_design options
        end

        def database
          @database || raise(StandardError, "no database defined!")
        end

        def design
          @design || raise(StandardError, "no database defined!")
        end

        def method_missing(method_name, *arguments, &block)
          view = find_view method_name
          view ? view.collection(*arguments) : super
        end

        def respond_to?(method_name)
          view = find_view method_name
          view ? true : super
        end

        private

        def initialize_database(options)
          url               = options[:url] || raise(ArgumentError, "no url was given to define the database")
          delete_if_exists  = options[:delete_if_exists]  || false
          create_if_missing = options[:create_if_missing] || false

          uri = URI.parse url
          server = Server.new :host => uri.host, :port => uri.port
          database = Database.new :server => server, :name => uri.path.gsub("/", "")
          @database = Configuration.register_database database

          if @database === database
            @database.delete_if_exists!   if delete_if_exists
            @database.create_if_missing!  if create_if_missing
          end
        end

        def initialize_design
          @design = Design.new @database, self, :id => self.to_s.underscore
          Configuration.register_design @design
        end

        def generate_class_view
          @design.generate_view Configuration::CLASS_VIEW_NAME
        end

        def push_design(options)
          push_design = options[:push_design] || false
          @design.push if push_design
        end

        def find_view(name)
          @design ? @design.views.select{ |view| view.name == name.to_s }.first : nil
        end

      end

    end

  end

end
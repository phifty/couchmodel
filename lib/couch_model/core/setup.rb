
module CouchModel

  module Core

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
          define_view_methods
          push_design options
        end

        def database
          @database || raise(StandardError, "no database defined!")
        end

        def design
          @design
        end

        private

        def initialize_database(options)
          url                     = options[:url] || raise(ArgumentError, "no url was given to define the database")
          setup_on_initialization = options[:setup_on_initialization] || false

          uri = URI.parse url
          server = Server.new :host => uri.host, :port => uri.port
          database = Database.new :server => server, :name => uri.path.gsub("/", "")
          @database = Configuration.register_database database

          @database.setup! options if setup_on_initialization && @database === database
        end

        def initialize_design
          @design = Design.new @database, self, :id => self.to_s.underscore
          Configuration.register_design @design
        end

        def generate_class_view
          @design.generate_view Configuration::CLASS_VIEW_NAME
        end

        def define_view_methods
          @design.views.each do |view|
            self.class.class_eval do
              define_method view.name do |*arguments|
                view.collection *arguments
              end
            end
          end
        end

        def push_design(options)
          setup_on_initialization = options[:setup_on_initialization] || false
          @design.push if setup_on_initialization
        end
        
      end

    end

  end

end

module CouchModel

  class Configuration

    CLASS_KEY       = "model_class".freeze unless defined?(CLASS_KEY)
    CLASS_VIEW_NAME = "all".freeze unless defined?(CLASS_VIEW_NAME)
    
    class << self

      @@fake_transport  = false
      @@databases       = [ ]
      @@designs         = [ ]

      def fake_transport=(value)
        @@fake_transport = value        
      end

      def fake_transport
        @@fake_transport
      end

      def design_directory=(value)
        @@design_directory = value
      end

      def design_directory
        class_variable_defined?(:@@design_directory) ? @@design_directory : ""
      end

      def register_database(database)
        result = @@databases.select{ |element| element == database }.first
        unless result
          @@databases << database
          result = database
        end
        result
      end

      def databases
        @@databases
      end

      def setup_databases(options = { })
        delete_if_exists  = options[:delete_if_exists]  || false
        create_if_missing = options[:create_if_missing] || false

        @@databases.each do |database|
          database.delete_if_exists!  if delete_if_exists
          database.create_if_missing! if create_if_missing
        end
      end

      def register_design(design)
        @@designs << design
      end

      def designs
        @@designs
      end

      def setup_designs
        @@designs.each do |design|
          design.push
        end
      end
      
    end

  end

end

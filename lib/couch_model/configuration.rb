
module CouchModel

  module Configuration

    CLASS_KEY       = "model_class".freeze unless defined?(CLASS_KEY)
    CLASS_VIEW_NAME = "all".freeze unless defined?(CLASS_VIEW_NAME)
    
    @fake_transport  = false
    @databases       = [ ]
    @designs         = [ ]

    def self.fake_transport=(value)
      @fake_transport = value
    end

    def self.fake_transport
      @fake_transport
    end

    def self.design_directory=(value)
      @design_directory = value
    end

    def self.design_directory
      instance_variable_defined?(:@design_directory) ? @design_directory : ""
    end

    def self.register_database(database)
      result = @databases.select{ |element| element == database }.first
      unless result
        @databases << database
        result = database
      end
      result
    end

    def self.databases
      @databases
    end

    def self.setup_databases(options = { })
      delete_if_exists  = options[:delete_if_exists]  || false
      create_if_missing = options[:create_if_missing] || false

      @databases.each do |database|
        database.delete_if_exists!  if delete_if_exists
        database.create_if_missing! if create_if_missing
      end
    end

    def self.register_design(design)
      @designs << design
    end

    def self.designs
      @designs
    end

    def self.setup_designs
      @designs.each do |design|
        design.push
      end
    end

  end

end

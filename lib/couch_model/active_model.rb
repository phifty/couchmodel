require File.expand_path(File.join(File.dirname(__FILE__), "..", "core_extension", "array"))
require File.expand_path(File.join(File.dirname(__FILE__), "base"))
gem 'activemodel'
require 'active_model'

module CouchModel

  # Extension of class Base to implement the ActiveModel interface.
  class Base
    extend ::ActiveModel::Naming
    extend ::ActiveModel::Callbacks
    extend ::ActiveModel::Translation
    include ::ActiveModel::Conversion
    include ::ActiveModel::Dirty
    include ::ActiveModel::Validations
    include ::ActiveModel::Serializers::JSON
    include ::ActiveModel::Serializers::Xml

    # The InvalidModelError is raised, e. g. if the save! method is called on an invalid model.
    class InvalidModelError < StandardError; end

    CALLBACKS = [ :initialize, :save, :create, :update, :destroy ].freeze unless defined?(CALLBACKS)

    define_model_callbacks *CALLBACKS

    CALLBACKS.each do |method_name|

      alias_method :"#{method_name}_without_callbacks", :"#{method_name}"

      define_method :"#{method_name}" do |*arguments|
        send :"_run_#{method_name}_callbacks" do
          send :"#{method_name}_without_callbacks", *arguments
        end
      end

    end

    alias new_record? new?

    def persisted?
      !new?
    end

    alias destroyed? new?

    def to_param
      persisted? ? id : nil
    end

    alias save_without_active_model save

    def save
      return false unless valid?
      result = save_without_active_model
      discard_changes!
      result
    end

    def save!
      raise InvalidModelError, "errors: #{errors.full_messages.join(' / ')}" unless valid?
      raise StandardError, "unknown error while saving model" unless save
      true
    end

    def update_attribute(name, value)
      update_attributes name => value
    end

    def update_attributes(attributes)
      self.attributes = attributes
      self.save
    end

    private

    def discard_changes!
      @previously_changed = changes
      @changed_attributes = { }
    end

    def merge_multiparameter_attributes(attributes)
      result = attributes.stringify_keys
      self.class.key_definitions.each do |key, definition|
        case definition[:type]
          when :date
            parameters = attributes.values_at(*(1..3).map{ |index| "#{key}(#{index}i)" }).map(&:to_i)
            result[key] = Date.civil *parameters rescue nil unless result[key].is_a?(Date)
          when :time
            parameters = attributes.values_at(*(1..6).map{ |index| "#{key}(#{index}i)" }).map(&:to_i)
            result[key] = Time.mktime *parameters rescue nil unless result[key].is_a?(Time)
        end
      end
      result
    end

    class << self

      alias key_accessor_without_dirty key_accessor

      def key_accessor(key, options = { })
        add_key key
        redefine_attribute_methods

        key_accessor_without_dirty key, options
        redefine_key_writer key
      end

      def create!(*arguments)
        model = new *arguments
        model.save!
        model
      end

      private

      def add_key(key)
        @keys ||= [ ]
        @keys << key
      end

      def redefine_attribute_methods
        undefine_attribute_methods
        define_attribute_methods @keys
      end

      def redefine_key_writer(key)
        alias_method :"#{key}_without_dirty=", :"#{key}="
        define_method :"#{key}=" do |value|
          send :"#{key}_will_change!"
          send :"#{key}_without_dirty=", value
        end
      end

    end

  end

end

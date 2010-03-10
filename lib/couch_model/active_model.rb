require File.expand_path(File.join(File.dirname(__FILE__), "..", "core_extension", "array"))
require File.expand_path(File.join(File.dirname(__FILE__), "base"))
gem 'activemodel'
require 'active_model'

module CouchModel

  class Base
    extend ::ActiveModel::Naming
    extend ::ActiveModel::Callbacks
    extend ::ActiveModel::Translation
    include ::ActiveModel::Conversion
    include ::ActiveModel::Dirty
    include ::ActiveModel::Validations
    include ::ActiveModel::Serializers::JSON
    include ::ActiveModel::Serializers::Xml

    CALLBACKS = [ :initialize, :save, :create, :update, :destroy ].freeze unless defined?(CALLBACKS)

    define_model_callbacks *CALLBACKS

    CALLBACKS.each do |method_name|

      alias :"#{method_name}_without_callbacks" :"#{method_name}"

      define_method :"#{method_name}" do |*arguments|
        send :"_run_#{method_name}_callbacks" do
          send :"#{method_name}_without_callbacks", *arguments
        end
      end

    end

    alias new_record? new?

    alias destroyed? new?

    alias save_without_active_model save

    def save
      return false unless valid?
      result = save_without_active_model
      discard_changes!
      result
    end

    private

    def discard_changes!
      @previously_changed = changes
      @changed_attributes = { }
    end

    class << self

      alias key_accessor_without_dirty key_accessor

      def key_accessor(key)
        add_key key
        redefine_attribute_methods

        key_accessor_without_dirty key

        alias_method :"#{key}_without_dirty=", :"#{key}="
        define_method :"#{key}=" do |value|
          send :"#{key}_will_change!"
          send :"#{key}_without_dirty=", value
        end
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

    end

  end

end

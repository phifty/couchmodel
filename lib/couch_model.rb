require 'rubygems'

require File.join(File.dirname(__FILE__), "couch_model", "configuration")
require File.join(File.dirname(__FILE__), "couch_model", "base")

begin
  gem 'activemodel'
  require 'active_model'

  require File.join(File.dirname(__FILE__), "couch_model", "active_model")

  # ActiveModel support is activated
rescue Gem::LoadError
  # ActiveModel support is deactivated
end

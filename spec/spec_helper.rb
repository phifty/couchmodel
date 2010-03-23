require 'rubygems'
gem 'rspec', '1.3.0'
require 'spec'

require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "couch_model", "configuration"))
require File.join(File.dirname(__FILE__), "fake_transport_helper")

CouchModel::Configuration.fake_transport = true
Spec::Runner.configure do |configuration|
  configuration.before :each do
    CouchModel::Transport.fake! if CouchModel::Configuration.fake_transport
  end
end

def use_real_transport!
  class_eval do

    before :all do
      CouchModel::Configuration.fake_transport = false
    end

    after :all do
      CouchModel::Configuration.fake_transport = true
    end

  end
end

require 'rubygems'
gem 'rspec', '>= 2.0.1'
require 'rspec'

require File.join(File.dirname(__FILE__), "fake_transport_helper")

FakeTransport.enable!
RSpec.configure do |configuration|
  configuration.before :each do
    FakeTransport.fake!
  end
end

def use_real_transport!
  class_eval do

    before :all do
      FakeTransport.disable!
    end

    after :all do
      FakeTransport.enable!
    end

  end
end

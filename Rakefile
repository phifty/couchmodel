require 'rubygems'
gem 'rspec'
require 'rspec'
require 'rdoc/task'
require 'rubygems/package_task'
require 'rspec/core/rake_task'

task :default => :spec

specification = Gem::Specification.new do |specification|
  specification.name              = "couchmodel"
  specification.version           = "0.1.5"
  specification.date              = "2010-07-15"

  specification.authors           = [ "Philipp Bruell" ]
  specification.email             = "b.phifty@gmail.com"
  specification.homepage          = "http://github.com/phifty/couchmodel"
  specification.rubyforge_project = "couchmodel"

  specification.summary           = "CouchModel provides an interface to easly handle CouchDB documents."
  specification.description       = "CouchModel provides an interface to easly handle CouchDB documents. It also comes with a ActiveModel implementation to integrate into an Rails 3 application."

  specification.has_rdoc          = true
  specification.files             = [ "README.rdoc", "LICENSE", "Rakefile" ] + Dir["lib/**/*"] + Dir["spec/**/*"]
  specification.extra_rdoc_files  = [ "README.rdoc" ]
  specification.require_path      = "lib"

  specification.test_files        = Dir["spec/**/*_spec.rb"]

  specification.add_development_dependency "rspec", ">= 2.0.1"
end

Gem::PackageTask.new(specification) do |package|
  package.gem_spec = specification
end

desc "Generate the rdoc"
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_files.add [ "README.rdoc", "lib/**/*.rb" ]
  rdoc.main   = "README.rdoc"
  rdoc.title  = "CouchModel interface to handle CouchDB documents."
end

desc "Run all specs in spec directory"
RSpec::Core::RakeTask.new do |task|
  task.pattern = "spec/lib/**/*_spec.rb"
end

namespace :spec do

  desc "Run all integration specs in spec/integration directory"
  RSpec::Core::RakeTask.new(:integration) do |task|
    task.pattern = "spec/integration/**/*_spec.rb"
  end

end

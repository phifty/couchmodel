# -*- encoding: utf-8 -*-

Gem::Specification.new do |specification|
  specification.name    = "couchmodel"
  specification.version = "0.1.0.beta4"
  specification.date    = "2010-03-21"

  specification.authors   = [ "Philipp Brüll" ]
  specification.email     = "b.phifty@gmail.com"
  specification.homepage  = "http://github.com/phifty/couchmodel"

  specification.summary     = "CouchModel provides an interface to easly handle CouchDB documents."
  specification.description = "CouchModel provides an interface to easly handle CouchDB documents. It also comes with a ActiveModel implementation to integrate into an Rails 3 application."

  specification.extra_rdoc_files      = [ "README.rdoc" ]
  specification.rdoc_options          = [ "--line-numbers", "--main", "README.rdoc" ]
  specification.require_paths         = [ "lib" ]
  specification.required_ruby_version = ">= 1.9.1"
  specification.rubygems_version      = "1.3.6"

  specification.files = [ "README.rdoc", "LICENSE", "Rakefile" ]
  specification.files += Dir["lib/**/*"]
  specification.files += Dir["spec/**/*"]

  specification.test_files = Dir["spec/**/*_spec.rb"]
end

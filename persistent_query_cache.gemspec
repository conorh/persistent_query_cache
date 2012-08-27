Gem::Specification.new do |s|
  s.name        = "persistent_query_cache"
  s.version     = 0.1
  s.date        = '2012-04-19'
  s.authors     = ["Conor Hunt"]
  s.email       = "conor@outertrack.com"
  s.homepage    = "https://github.com/conorh/persistent_query_cache"
  s.summary     = "Persistent Query Cache extends the Rails 3 Query Cache to persist the results of some simple SQL queries across requests."
  s.description = "Persistent Query Cache for Rails 3"

  s.files = ['README.md','init.rb'] + Dir['lib/*.rb'].to_a
  s.rdoc_options     = ["--charset=UTF-8"]
  s.require_path     = "lib"

  s.add_dependency "activerecord", [">= 3.1"]
end
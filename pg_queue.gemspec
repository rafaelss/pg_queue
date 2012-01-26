# -*- encoding: utf-8 -*-
require File.expand_path('../lib/pg_queue/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Rafael Souza"]
  gem.email         = ["me@rafaelss.com"]
  gem.description   = %q{Some experimentations with LISTEN/NOTIFY for background jobs}
  gem.summary       = %q{Background jobs using PostgreSQL's LISTEN/NOTIFY}
  gem.homepage      = "http://github.com/rafaelss/pg_queue"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "pg_queue"
  gem.require_paths = ["lib"]
  gem.version       = PgQueue::VERSION

  gem.add_dependency "pg", "~> 0.12.2"
end

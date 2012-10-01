# -*- encoding: utf-8 -*-
$:.push File.expand_path(File.join('..', 'lib'), __FILE__)
require('chained/version')

Gem::Specification.new do |s|
  s.name        = 'chained'
  s.version     = Chained::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = [
                   'Ken Coar',
                  ]
  s.email       = [
                   'The.Rodent.of.Unusual.Size@GMail.Com',
                  ]
  s.homepage    = ''
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = 'chained'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = [
                     'lib',
                    ]
  s.add_dependency(%q<versionomy>,		[ '>= 0' ])
  s.add_dependency(%q<ruby-debug>,		[ '>= 0' ])
  s.add_development_dependency(%q<test-unit>,	[ '>= 0' ])
end

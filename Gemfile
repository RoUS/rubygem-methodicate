source('http://rubygems.org')
#
# Specify your gem's dependencies in chained.gemspec
#
gemspec

group(:development) do
  gem('redcarpet')
  gem('yard')
end

group(:test, :development) do
  gem('rake',			'>= 0.8.7')
  gem('cucumber',		'~> 0.10.2')
  gem('rcov',			'>= 0.9.9',
      :platforms		=> :mri)
  gem('test-unit',		'>= 2.3',
      :require			=> 'test/unit')
end


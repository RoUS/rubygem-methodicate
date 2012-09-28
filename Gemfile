source('http://rubygems.org')
#
# Specify your gem's dependencies in chained.gemspec
#
gemspec

group(:development) do
  gem('yard')
end

group(:test, :development) do
  gem('rake',			'>= 0.8.7')
  gem('redcarpet')
  gem('cucumber',		'~> 0.10.2')
  gem('rcov',			'>= 0.9.9',
      :platforms		=> :mri)
end


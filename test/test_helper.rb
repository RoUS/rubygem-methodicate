Proc.new {
  [ '.', File.join(File.dirname(__FILE__), '..', 'lib') ].each do |p|
    xp = File.expand_path(p)
    $:.unshift(p) unless ($:.include?(p) || $:.include?(xp))
  end
}.call
require('stringio')
require('test/unit')
require('chained')
require('ruby-debug')
Debugger.start

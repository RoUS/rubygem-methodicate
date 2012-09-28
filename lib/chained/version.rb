require('rubygems')
require('versionomy')

class Chained
  #
  # Our gem's version as a Versionomy object.  (Good for comparisons
  # and field extractions.
  #
  Version = Versionomy.parse('0.1.0')

  #
  # Our gem's version as a straight String extracted from the
  # authoritative Versionomy object.  Used by the gemspec, etc.
  #
  VERSION = Version.to_s
end

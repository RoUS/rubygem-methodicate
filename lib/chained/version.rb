# -*- coding: utf-8 -*-
#--
#   Copyright © 2012 Ken Coar
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#++
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

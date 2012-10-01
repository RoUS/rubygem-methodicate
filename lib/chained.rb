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
require('chained/version')
require('ruby-debug')
Debugger.start

#
# Add a #chained? method to the Object ancestor class if it isn't already
# there.
#
unless (Object.method_defined?(:chained?))
  #
  # Open the global ancestor class Object and add the
  # <tt>#chained?</tt> method to it so that the method is available on
  # <b>all</b> objects.
  #
  class Object
    #
    # Since the Chained class conceals its involvement in object
    # access, this method provides an authoritative way to find out if
    # a particular object is wrapped or not.
    #
    # @return [Boolean]
    #  By default, {#chained?} will return <tt>false</tt> for all objects.
    #
    def chained?
      return false
    end
  end
end

#
# The <tt>Chained</tt> class provides a wrapper mechanism so that
# nested objects (particularly
# {http://ruby-doc.org/core-1.9.3/Enumerable.html Enumerable} ones)
# can be accessed using a method-chain syntax regardless of the actual
# object type.  For example:
#
# @example Illustrative mixed structure to be chained:
#  hsh = {
#    'A'     => 'a string',
#    'B'     => :a_symbol,
#    'a'     => [ 'an', 'array' ],
#    :a      => {
#      'h1'  => 'hv1',
#      :h2   => [ 'h', 'v', '2' ],
#      'H3'  => [
#                 [ 'deep', 'array'],
#                 { :deeper => :hash },
#               ],
#    },
#  }
#  data = Chained.new(hsh)
#
# @example Accessing attributes/elements <i>via</i> method-like syntax:
#  data.A
#  => "a string"
#  data.B
#  => :a_symbol
#
# @example <tt>Symbol</tt> keys dominate <tt>String</tt> keys:
#  data.a
#  => { "h1" => "hv1", :h2 => [ "h", "v", "2" ], "H3" => [[ "deep", "array" ], { :deeper => :hash }] }
#
# @example Indexed access is still available (and sometimes required):
#  data['A']
#  => "a string"
#  data[:a]
#  => { "h1" => "hv1", :h2 => [ "h", "v", "2" ], "H3" => [[ "deep", "array" ], { :deeper => :hash }] }
#  data['a']
#  => [ 'an', 'array' ]
#
# @example Going deeper:
#  data.a.H3.deeper
#  => :hash
#  data.a.h2[1]
#  => "v"
#
class Chained

  class << self

    #
    # Array of symbols identifying methods that should be created on
    # the wrapper to pass directly through to the wrapped object.
    #
    # @return [Array<Symbol>]
    #  Current list of passthrough methods.
    #
    attr_accessor(:passthrough_methods)

    #
    # Array of class that <b>should not</b> be wrapped in a new
    # instance of {Chained} when they occur as the result of an
    # operation in the {#chained_method_missing method_missing}
    # instance method.
    #
    # @return [Array<Class>]
    #  Current list of classes that cannot be chained.
    #
    attr_accessor(:exclusions)

  end

  #
  # Instance methods to supersede in order to make ours a transparent
  # wrapping as much as possible.
  #
  # @note
  #  As part of the transparency imperative, the {Chained} object
  #  wrapper will 'fake' the response to the canonical {#class} and
  #  comparison methods (<tt>:\<</tt>, <tt>==</tt>, <i>etc</i>.), and
  #  pass them through to the wrapped object rather than using the
  #  version inherited by the wrapper itself.  To determine if an
  #  object is wrapped or not, use the {#chained?} method.
  #
  # @note
  #  To ensure that comparisons are made against the wrapped object
  #  and not the wrapper, a {Chained} object <b>must</b> be on the
  #  <abbr title="left-hand side">LHS</abbr> of the comparison
  #  operator.
  #
  self.passthrough_methods	= [
                                   :<,
                                   :<=,
                                   :==,
                                   :eql?,
                                   :>,
                                   :>=,
                                   :<=>,
                                   :class,
                                   :inspect,
                                   :instance_of?,
                                   :is_a?,
                                   :kind_of?,
                                   :to_s,
                                   :to_str,
                                  ]
  self.exclusions		= [
                                   NilClass,
                                   Fixnum,
                                   String,
                                   Symbol,
                                   TrueClass,
                                   FalseClass,
                                  ]
  #
  # Creates a new {Chained} instance that enwraps the given object
  # with our access methods and techniques.  We create methods on
  # ourself that pass directly through to the wrapped object according
  # to the {passthrough_methods} array, and lastly add an alias on
  # ourself for our {#chained_method_missing method_missing} method
  # (done last so that it doesn't get triggered by anything in our
  # constructor).
  #
  # @param [Object] contents_p
  #  Object to be wrapped by our access method package.
  # @param [Boolean] honour_exclusions
  #  Intended for internal use only, this flag allows even instances
  #  of excluded classes to be wrapped.
  # @return [Chained]
  #  The original object, enclosed in an instance of our {Chained} class.
  # @raise [ArgumentError]
  #  if the class of <tt>contents_p</tt> is on the exclusion list.
  # @see exclusions
  # @see passthrough_methods
  #
  def initialize(contents_p, honour_exclusions=true)
    if (honour_exclusions && Chained.exclusions.include?(contents_p.class))
      raise ArgumentError.new("cannot wrap #<#{contents_p.class.name}> " +
                              "instance; #{contents_p.class.name} " +
                              'is on the exclusion list')
    end
    @contents = contents_p
    #
    # Define the superceding instance methods if the wrapped object
    # has them.
    #
    Chained.passthrough_methods.each do |mname_sym|
      next unless (@contents.respond_to?(mname_sym))
      #
      # We make a minimal stab at maintaining the arity of the
      # original method; 'minimal' because we only distinguish between
      # 'takes arguments' and 'doesn't take arguments.'
      #
      if (@contents.method(mname_sym).arity.zero?)
        self.instance_eval(<<-EOC)
          def #{mname_sym}
            return @contents.#{mname_sym}
          end
        EOC
      else
        self.instance_eval(<<-EOC)
          def #{mname_sym}(*args)
            return @contents.#{mname_sym}(*args)
          end
        EOC
      end
    end
    #
    # Now that all the funky usages of <tt>#respond_to?</tt> have
    # been made, we can plug in our {#chained_method_missing
    # method_missing} hook -- <b>solely</b> on this instance of Chained.
    #
    class << self
      alias_method(:method_missing, :chained_method_missing)
    end
  end

  #
  # The <tt>chained</tt> gem adds a {Object#chained? chained?} method
  # so that unwrapped objects can be easily distinguished from those
  # which are chainable.  Since this <i>is</i> the {Chained} class,
  # that method must obviously return <tt>true</tt> in this context.
  #
  # @return [Boolean]
  #  <tt>true</tt> (because we <b>are</b> {Chained}, after all).
  #
  def chained?
    return true
  end

  #
  # Sometimes it's necessary (or at least desirable) to be able to
  # access the object inside the wrapper.  This method returns it so
  # that it can be manipulated directly.
  #
  # @return [Object]
  #  Return the raw enclosed object.  This allows both outsiders and
  #  ourselves the ability to get at the original's instance methods.
  #
  def unchained
    return @contents
  end

  #
  # @!method method_missing(mname_sym, *args)
  #
  # Methods actually defined on a {Chained} instance bypass this
  # mechanism (which is why we keep such methods to a minimum; we
  # don't want to inadvertently occlude any methods on the wrapped
  # object).  However, methods that were probably intended for the
  # wrapped object <i>should</i> be intercepted here.
  #
  # The function of this method is the <i>raison d'être</i> of the
  # {Chained} gem.
  #
  # 1. If the wrapped object has the requested method, we
  #    send it along.
  # 2. If the wrapped object supports indexing <i>via</i> <tt>[]</tt>,
  #    we try the requested method 'name' as an index.  If it isn't
  #    found, we try again with the name-as-a-string.  If that's no go
  #    and the string is interpretable as an integer, we try that.
  # 3. Otherwise, we just send the request along as for #1, except
  #    that we expect it to raise an exception or be otherwise handled
  #    outside of our scope.
  #
  # In all cases, we wrap the result in a new instance of {Chained} to
  # maintain the semantics on down the line -- unless the class of the
  # result is in the {exclusions} list.
  #
  # @param [Symbol] mname_sym
  #  Symbolic name to be treated as either a method or an index of the
  #  wrapped object.
  # @param [Array] args
  #  Additional arguments for the method (if any).
  # @return [Chained, Object]
  #  Whatever we return (short of an exception or an instance of an
  #  excluded class) will be itself enwrapped in a {Chained} instance.
  #
  def chained_method_missing(mname_sym, *args)
    chainer = Chained
    if (self.respond_to?(mname_sym))
      return self.__send__(mname_sym, *args)
    elsif (@contents.respond_to?(mname_sym))
      results = chainer.new(@contents.send(mname_sym, *args), false)
    elsif (@contents.respond_to?(:[]))
      keyval = mname_sym
      catch(:gotakey) do
        throw(:gotakey) if (@contents.include?(keyval))
        keyval = mname_sym.to_s
        throw(:gotakey) if (@contents.include?(keyval))
        if (keyval.respond_to?(:to_i) && (keyval.to_i.to_s == keyval))
          keyval = keyval.to_i
        end
        throw(:gotakey) if (@contents.include?(keyval))
      end
      if (args.empty?)
        keyargs = [ keyval ]
      else
        keyargs = [ keyval, *args ]
      end
      results = chainer.new(@contents[*keyargs], false)
    else
      results = @contents.send(mname_sym, *args)
    end
    #
    # Some types of responses we don't want to wrap.
    #
    if (Chained.exclusions.include?(results.unchained.class))
      results = results.unchained
    end
    return results
  end

end

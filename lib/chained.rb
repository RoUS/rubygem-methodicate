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
# nested objects (particularly {Enumerable} ones) can be accessed
# using a method-chain syntax regardless of the actual object type.
# For example:
#
#  hsh = \{
#    'A'     => 'a string',
#    'B'     => :a_symbol,
#    'a'     => [ 'an', 'array' ],
#    :a      => \{
#      'h1'  => 'hv1',
#      :h2   => [ 'h', 'v', '2' ],
#      'H3'  => [
#                 [ 'deep', 'array'],
#                 \{ :deeper => :hash },
#               ],
#    },
#  }
class Chained

  #
  # Instance methods to supersede in order to make ours a transparent
  # wrapping as much as possible.
  #
  CHAINED_OVERRIDES	= [
                           :inspect,
                           :instance_of?,
                           :is_a?,
                           :kind_of?,
                           #:respond_to?,
                           :to_s,
                           :to_str,
                          ]
  UNCHAINABLE_CLASSES	= [
                           NilClass,
                           TrueClass,
                           FalseClass,
                           Fixnum,
                           String,
                          ]
  #
  # Creates a new <tt>{Chained}</tt> instance that enwraps the given
  # object with our access methods and techniques.
  #
  # @param [Object] contents_p
  #  Object to be wrapped by our access method package.
  # @return [Chained]
  #  The original object, enclosed in an instance of our {Chained} class.
  #
  def initialize(contents_p)
    @contents = contents_p
    #
    # Define the superceding instance methods if the wrapped object
    # has them.
    #
    CHAINED_OVERRIDES.each do |mname_sym|
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
    class << self
      alias_method(:method_missing, :chained_method_missing)
    end
  end

  #
  # The <tt>chained</tt> gem adds a {Object#chained?} method so that
  # unwrapped objects can be easily distinguished from those which are
  # chainable.  Since this <i>is</i> the {Chain} class, here that
  # method must obviously return <tt>true</tt>.
  #
  # @return [Boolean]
  #  <tt>true</tt> (because we <b>are</b> {Chained}, after all).
  #
  def chained?
    return true
  end

  #
  # Sometimes it's necessary (or at least desirable) to be able to
  # access the object inside the wrapper.  This method ({#unchained})
  # returns it so that it can be manipulated directly.
  #
  # @return [Object]
  #  Return the raw enclosed object.  This allows both outsiders and
  #  ourselves the ability to get at the original's instance methods.
  #
  def unchained
    return @contents
  end

  #
  # As part of the transparency imperative, the {Chained} object
  # wrapper will 'fake' the response to the canonical {#class} method,
  # and return that from the wrapped object rather than from the
  # wrapper.  To determine if an object is wrapped or not, use the
  # {#chained?} method.
  #
  # @return [Class]
  #  Return the class of the enclosed object, rather than ourselves.
  #
  def class
    return @contents.class
  end

  #
  # Methods actually defined on a {Chained} instance bypass this
  # mechanism (which is why we keep such to a minimum).  However,
  # methods that were probably intended for the wrapped object
  # <i>should</i> be intercepted here.
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
  # maintain the semantics on down the line.
  #
  # @param [Symbol] mname_sym
  #  Symbolic name to be treated as either a method or an index of the
  #  wrapped object.
  # @param [Array] args
  #  Additional arguments for the method (if any).
  # @return [Chained]
  #  Whatever we return (short of an exception) will be itself
  #  enwrapped in a {Chained} instance.
  #
  def chained_method_missing(mname_sym, *args)
    chainer = Chained
    if (self.respond_to?(mname_sym))
      return self.__send__(mname_sym, *args)
    elsif (@contents.respond_to?(mname_sym))
      results = chainer.new(@contents.send(mname_sym, *args))
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
      results = chainer.new(@contents[*keyargs])
    else
      results = @contents.send(mname_sym, *args)
    end
    #
    # Some types of responses we don't want to wrap.
    #
    if (UNCHAINABLE_CLASSES.include?(results.unchained.class))
      results = results.unchained
    end
    return results
  end

end

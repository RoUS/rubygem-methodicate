require('rubygems')
require('chained/version')

#
# Add a #chained? method to the Object ancestor class if it isn't already
# there.
#
unless (Object.method_defined?(:chained?))
  class Object
    def chained?
      return false
    end
  end
end

class Chained

  #
  # Instance methods to supersede in order to make ours a transparent
  # wrapping as much as possible.
  #
  CHAINED_METHODS = [
                     :inspect,
                     :to_s,
                     :to_str,
                    ]

  #
  # @param [Object] contents_p
  #  Object to be contained within our access method package.
  # @returns [Chained]
  #  The original object, enclosed in an instance of our Chained class.
  #
  def initialize(contents_p)
    @contents = contents_p
    #
    # Define the superceding instance methods if the wrapped object
    # has them.
    #
    CHAINED_METHODS.each do |mname_sym|
      next unless (@contents.respond_to?(mname_sym))
      #
      # We make a minimal stab at maintaining the arity of the
      # original method; 'minimal' because we only distinguish between
      # 'takes arguments' and 'doesn't take arguments.'
      #
      if (@contents.method(mname_sym).arity.zero?)
        self.eval(<<-EOC)
          def #{mname_sym}
            return @contents.#{mname_sym}
          end
        EOC
      else
        self.eval(<<-EOC)
          def #{mname_sym}(*args)
            return @contents.#{mname_sym}(*args)
          end
        EOC
      end
    end
  end

  #
  # @return [Boolean]
  #  <tt>true</tt> (because we <b>are</b> Chained, after all).
  #
  def chained?
    return true
  end

  #
  # @return [Object]
  #  Return the raw enclosed object.  This allows both outsiders and
  #  ourselves the ability to get at the original's instance methods.
  #
  def unchained
    return @contents
  end

  #
  # @return [Class]
  #  Return the class of the enclosed object, rather than ourselves.
  #
  def class
    return @contents.class
  end

  #
  # @param [Symbol] mname_sym
  # @param [Array] args
  # @return [Chained, Object]
  #
  def method_missing(mname_sym, *args)
    chainer = Chained
    if (@contents.respond_to?(mname_sym))
      results = chainer.new(@contents.send(mname_sym, *args))
    elsif (@contents.respond_to?(:[]) && args.empty?)
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
      keyargs = [ keyval, *args ]
      results = chainer.new(@contents[*keyargs])
    else
      results = @contents.send(mname_sym, *args)
    end
    return results
  end

end

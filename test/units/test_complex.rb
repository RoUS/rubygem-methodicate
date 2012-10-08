require('rubygems')
require('test_helper')
require('ostruct')

#
# Test proper access to wrapped complex objects.
#
module Tests

  #
  # Test handling of nested/mixed arrays, hashes, scalars, <i>et
  # cetera</i>.
  #
  class TestMethodicatedComplex < Test::Unit::TestCase

    TDatum01 = {
      'A'	=> 'a string',
      'B'	=> :a_symbol,
      'a'	=> [ 'an', 'array' ],
      :a	=> {
        'h1'	=> 'hv1',
        :h2	=> [ 'h', 'v', '2' ],
        'H3'	=> [
		    [ 'deep', 'array'],
		    { :deeper => :hash },
		   ],
      },
    }

    #
    # Given a test object that's a fairly complex mix of hashes,
    # arrays, and scalars, make sure everything works right.
    #
    def test_101_empty_to_sparse

      tchain = Methodicate.new(TDatum01)
      assert(tchain.methodicated?,
             'Testing that "methodicate.new(complex)" is chained')
      assert_equal(TDatum01['A'],		tchain.A,
                   'Testing that "methodicate(complex).A == hash["A"]"')
      assert_equal(TDatum01['A'],		tchain['A'],
                   'Testing that "methodicate(complex)["A"] == hash["A"]"')
      assert_equal(TDatum01['B'],		tchain.B,
                   'Testing that "methodicate(complex).B == hash["B"]"')
      assert_equal(TDatum01['B'],		tchain['B'],
                   'Testing that "methodicate(complex)["B"] == hash["B"]"')

      #
      # Note that the following assertions *must* reverse the
      # 'expected' and 'actual' arguments so that the #== method will
      # be called on the *methodicated* value (which will pass it along),
      # and not the *reference* value (which will try to compare to a
      # hash).
      #
      assert_equal(tchain.a,			TDatum01[:a],
                   'Testing that "methodicate(complex).a == hash[:a]"')
      assert_equal(tchain[:a],			TDatum01[:a],
                   'Testing that "methodicate(complex)[:a] == hash[:a]"')
      assert_equal(tchain['a'],			TDatum01['a'],
                   'Testing that "methodicate(complex)["a"] == hash["a"]"')

      #
      # Revert to 'expected, actual' order.
      #
      assert_equal(TDatum01['a'].first,		tchain['a'].first)
      assert_equal(TDatum01['a'][0],		tchain['a'][0])
      assert_equal(TDatum01['a'][1],		tchain['a'][1])
      assert_equal(TDatum01['a'].last,		tchain['a'].last)

      assert_equal(TDatum01[:a]['h1'],		tchain.a['h1'])
      assert_equal(TDatum01[:a]['h1'],		tchain.a.h1)
      #
      # More reversals
      #
      assert_equal(tchain.a[:h2],		TDatum01[:a][:h2])
      assert_equal(tchain.a[:h2][0],		TDatum01[:a][:h2][0])
      assert_equal(tchain.a[:h2][1],		TDatum01[:a][:h2][1])
      assert_equal(tchain.a[:h2][2],		TDatum01[:a][:h2][2])

      assert_equal(tchain.a.h2,			TDatum01[:a][:h2])
      assert_equal(tchain.a.h2[0],		TDatum01[:a][:h2][0])
      assert_equal(tchain.a.h2[1],		TDatum01[:a][:h2][1])
      assert_equal(tchain.a.h2[2],		TDatum01[:a][:h2][2])

      assert_equal(tchain.a['H3'],		TDatum01[:a]['H3'])
      assert_equal(tchain.a['H3'][0],		TDatum01[:a]['H3'][0])
      assert_equal(tchain.a['H3'][0][0],	TDatum01[:a]['H3'][0][0])
      assert_equal(tchain.a['H3'][0][1],	TDatum01[:a]['H3'][0][1])
      assert_equal(tchain.a['H3'][0][2],	TDatum01[:a]['H3'][0][2])
      assert_equal(tchain.a['H3'][1],		TDatum01[:a]['H3'][1])
      assert_equal(tchain.a['H3'][1].keys,	TDatum01[:a]['H3'][1].keys)
      assert_equal(tchain.a['H3'][1][:deeper],	TDatum01[:a]['H3'][1][:deeper])
      assert_equal(tchain.a['H3'][1].deeper,	TDatum01[:a]['H3'][1][:deeper])

      assert_equal(tchain.a.H3,			TDatum01[:a]['H3'])
      assert_equal(tchain.a.H3[0],		TDatum01[:a]['H3'][0])
      assert_equal(tchain.a.H3[0][0],		TDatum01[:a]['H3'][0][0])
      assert_equal(tchain.a.H3[0][1],		TDatum01[:a]['H3'][0][1])
      assert_equal(tchain.a.H3[0][2],		TDatum01[:a]['H3'][0][2])
      assert_equal(tchain.a.H3[1],		TDatum01[:a]['H3'][1])
      assert_equal(tchain.a.H3[1].keys,		TDatum01[:a]['H3'][1].keys)
      assert_equal(tchain.a.H3[1][:deeper],	TDatum01[:a]['H3'][1][:deeper])
      assert_equal(tchain.a.H3[1].deeper,	TDatum01[:a]['H3'][1][:deeper])
    end

    #
    # @todo
    #  The code here is *really* ugly; automate is somehow, probably
    #  with reference to {Methodicate.exclusions} rather than
    #  hard-coding expected values for #methodicated? .
    #
    def test_201_openstruct
      tdatum2 = OpenStruct.new(
                               #
                               # ._scalar => String
                               #
                               :_scalarM? => false,
                               :_scalar	=> 'scalar',
                               #
                               # ._array => Array
                               #
                               :_arrayM? => true,
                               :_array	=> 'array'.split(%r!!),
                               #
                               # ._hash => Hash
                               #
                               :_hashM?	=> true,
                               :_hash	=> {
                                 #
                                 # ._hash[:symScalarString] => String
                                 #
                                 :symScalarStringM?	=> false,
                                 :symScalarString	=> 'symScalarString-value',
                                 #
                                 # ._hash['strScalarString'] => String
                                 #
                                 :strScalarStringM?	=> false,
                                 'strScalarString'	=> 'strScalarString-value',
                                 #
                                 # ._hash[:symArray] => Array
                                 #
                                 :symArrayM?		=> true,
                                 :symArray		=> [1, 2, 3],
                                 #
                                 # ._hash['strArray'] => Array
                                 #
                                 :strArrayM?		=> true,
                                 'strArray'		=> [3, 2, 1],
                                 #
                                 # ._hash[:symHash] => Hash
                                 #
                                 :symHashM?		=> true,
                                 :symHash		=> {
                                   #
                                   # ._hash[:symHash][:symKey] => String
                                   #
                                   :symKeyM?		=> false,
                                   :symKey		=> 'symValue',
                                   #
                                   # ._hash[:symHash]['strKey'] => String
                                   #
                                   :strKeyM?		=> false,
                                   'strKey'		=> 'strValue',
                                   #
                                   # ._hash[:symHash][[1,2,3]] => String
                                   #
                                   :arrayKeyM?		=> false,
                                   [1,2,3]		=> 'arrayValue',
                                 },
                                 :strHashM?		=> true,
                                 'strHash'		=> {
                                   #
                                   # ._hash['strHash'][:symKey] => String
                                   #
                                   :symKeyM?		=> false,
                                   :symKey		=> 'symValue',
                                   #
                                   # ._hash['strHash']['strKey'] => String
                                   #
                                   :strKeyM?		=> false,
                                   'strKey'		=> 'strValue',
                                   #
                                   # ._hash['strHash'][[3,2,1]] => String
                                   #
                                   :arrayKeyM?		=> false,
                                   [3,2,1]		=> 'arrayValue',
                                 },
                               }
                               )
      tchain = Methodicate.new(tdatum2)
      assert(tchain.methodicated?,
             '(Methodicate.new(OpenStruct.new(..)).methodicated?) => true')

      #
      # Test raw._scalar
      #
      assert(! tdatum2._scalar.methodicated?,
             '(raw.methodicated?) => false')
      assert_equal(tdatum2._scalarM?,
                   tchain._scalar.methodicated?,
                   '(methed._scalar => String).methodicated? => false')
      assert_equal(tchain._scalar,
                   tdatum2._scalar,
                   '(methed._scalar == raw._scalar) => true')

      #
      # Test raw._array
      #
      assert(! tdatum2._array.methodicated?,
             '((raw._array).methodicated?) => false')
      assert_equal(tdatum2._arrayM?,
                   tchain._array.methodicated?,
                   '((methed._array).methodicated?) => true')
      assert_equal(tchain._array,
                   tdatum2._array,
                   '(methed._array == raw._array) => true')

      #
      # Test raw._hash
      #
      assert(! tdatum2._hash.methodicated?,
             '((raw._hash).methodicated?) => false')
      assert_equal(tdatum2._hashM?,
                   tchain._hash.methodicated?,
                   "((methed._hash).methodicated?) => #{tdatum2._hashM?.inspect}")
      assert_equal(tchain._hash,
                   tdatum2._hash,
                   '(methed._hash == raw._hash) => true')

      #
      # Test ._hash[:symScalarString] => String
      #
      assert(! tdatum2._hash[:symScalarString].methodicated?,
             '((raw._hash[:symScalarString] #= String).methodicated?) => false')
      assert_equal(tdatum2._hash[:symScalarStringM?],
                   tchain._hash.symScalarString.methodicated?,
                   "((methed._hash.symScalarString #= String).methodicated?) => #{tdatum2._hash[:symScalarStringM?].inspect}")
      assert_equal(tchain._hash.symScalarString,
                   tdatum2._hash[:symScalarString],
                   '(methed._hash.symScalarString == raw._hash[:symScalarString]) => true')
      assert_equal(tdatum2._hash[:symScalarStringM?],
                   tchain._hash[:symScalarString].methodicated?,
                   "((methed._hash[:symScalarString] #= String).methodicated?) => #{tdatum2._hash[:symScalarStringM?].inspect}")
      assert_equal(tchain._hash[:symScalarString],
                   tdatum2._hash[:symScalarString],
                   '(methed._hash[:symScalarString] == raw._hash[:symScalarString]) => true')

      #
      # Test ._hash['strScalarString'] => String
      #
      assert(! tdatum2._hash['strScalarString'].methodicated?,
             '((raw._hash["strScalarString"] #= String).methodicated?) => false')
      assert_equal(tdatum2._hash[:strScalarStringM?],
                   tchain._hash.strScalarString.methodicated?,
                   '((methed._hash.strScalarString #= String).methodicated?) => false')
      assert_equal(tchain._hash.strScalarString,
                   tdatum2._hash['strScalarString'],
                   '(methed._hash.strScalarString == raw._hash["strScalarString"]) => true')

      #
      # Test ._hash[:symArray] => Array
      #
      assert(! tdatum2._hash[:symArray].methodicated?,
             '((raw._hash[:symArray] #= Array).methodicated?) => false')
      assert_equal(tdatum2._hash[:symArrayM?],
                   tchain._hash.symArray.methodicated?,
                   '((methed._hash.symArray #= Array).methodicated?) => true')
      assert_equal(tdatum2._hash[:symArrayM?],
                   tchain._hash[:symArray].methodicated?,
                   '((methed._hash[:symArray] #= Array).methodicated?) => true')
      assert_equal(tchain._hash.symArray,
                   tdatum2._hash[:symArray],
                   '(methed._hash.symArray == raw._hash[:symArray]) => true')
      assert_equal(tchain._hash[:symArray],
                   tdatum2._hash[:symArray],
                   '(methed._hash[:symArray] == raw._hash[:symArray]) => true')

      #
      # Test ._hash['strArray'] => Array
      #
      assert(! tdatum2._hash['strArray'].methodicated?,
             '((raw._hash["strArray"] #= Array).methodicated?) => false')
      assert_equal(tdatum2._hash[:strArrayM?],
                   tchain._hash.strArray.methodicated?,
                   '((methed._hash.strArray #= Array).methodicated?) => true')
      assert_equal(tdatum2._hash[:strArrayM?],
                   tchain._hash['strArray'].methodicated?,
                   '((methed._hash["strArray"] #= Array).methodicated?) => true')
      assert_equal(tchain._hash.strArray,
                   tdatum2._hash['strArray'],
                   '(methed._hash.strArray == raw._hash["strArray"]) => true')
      assert_equal(tchain._hash['strArray'],
                   tdatum2._hash['strArray'],
                   '(methed._hash["strArray"] == raw._hash["strArray"]) => true')

      #
      # Test ._hash[:symHash] => Hash
      #
      assert(! tdatum2._hash[:symHash].methodicated?,
             '((raw._hash[:symHash] #= Hash).methodicated?) => false')
      assert_equal(tdatum2._hash[:symHashM?],
                   tchain._hash.symHash.methodicated?,
                   "((methed._hash.symHash #= Hash).methodicated?) => #{tdatum2._hash[:symHashM?].inspect}")
      assert_equal(tdatum2._hash[:symHashM?],
                   tchain._hash[:symHash].methodicated?,
                   "((methed._hash[:symHash] #= Hash).methodicated?) => #{tdatum2._hash[:symHashM?].inspect}")
      assert_equal(tchain._hash.symHash,
                   tdatum2._hash[:symHash],
                   '(methed._hash.symHash == raw._hash[:symHash]) => true')
      assert_equal(tchain._hash[:symHash],
                   tdatum2._hash[:symHash],
                   '(methed._hash[:symHash] == raw._hash[:symHash]) => true')

      #
      # Test ._hash[:symHash][:symKey] => String
      #
      assert(! tdatum2._hash[:symHash][:symKey].methodicated?,
             '((raw._hash[:symHash][:symKey] #= String).methodicated?) => false')
      assert_equal(tdatum2._hash[:symHash][:symKeyM?],
                   tchain._hash.symHash.symKey.methodicated?,
                   "((methed._hash.symHash.symKey #= String).methodicated?) => #{tdatum2._hash[:symHash][:symKeyM?].inspect}")
      assert_equal(tdatum2._hash[:symHash][:symKeyM?],
                   tchain._hash[:symHash][:symKey].methodicated?,
                   "((methed._hash[:symHash][:symKey] #= String).methodicated?) => #{tdatum2._hash[:symHash][:symKeyM?].inspect}")
      assert_equal(tchain._hash.symHash.symKey,
                   tdatum2._hash[:symHash][:symKey],
                   '(methed._hash.symHash.symKey == raw._hash[:symHash][:symKey]) => true')
      assert_equal(tchain._hash[:symHash][:symKey],
                   tdatum2._hash[:symHash][:symKey],
                   '(methed._hash[:symHash][:symKey] == raw._hash[:symHash][:symKey]) => true')

      #
      # Test ._hash[:symHash]['strKey'] => String
      #
      assert(! tdatum2._hash[:symHash]['strKey'].methodicated?,
             '((raw._hash[:symHash]["strKey"] #= String).methodicated?) => false')
      assert_equal(tdatum2._hash[:symHash][:strKeyM?],
                   tchain._hash.symHash.strKey.methodicated?,
                   "((methed._hash.symHash.strKey #= String).methodicated?) => #{tdatum2._hash[:symHash][:strKeyM?].inspect}")
      assert_equal(tdatum2._hash[:symHash][:strKeyM?],
                   tchain._hash[:symHash]['strKey'].methodicated?,
                   "((methed._hash[:symHash]['strKey'] #= String).methodicated?) => #{tdatum2._hash[:symHash][:strKeyM?].inspect}")
      assert_equal(tchain._hash.symHash.strKey,
                   tdatum2._hash[:symHash]['strKey'],
                   '(methed._hash.symHash.strKey == raw._hash[:symHash]["strKey"]) => true')
      assert_equal(tchain._hash[:symHash]['strKey'],
                   tdatum2._hash[:symHash]['strKey'],
                   '(methed._hash[:symHash]["strKey"] == raw._hash[:symHash]["strKey"]) => false')

      #
      # Test ._hash['strHash'] => Hash
      #
      assert(! tdatum2._hash['strHash'].methodicated?,
             '((raw._hash["strHash"] #= Hash).methodicated?) => false')
      assert_equal(tdatum2._hash[:strHashM?],
                   tchain._hash.strHash.methodicated?,
                   "((methed._hash.strHash #= Hash).methodicated?) => #{tdatum2._hash[:strHashM?].inspect}")
      assert_equal(tdatum2._hash[:strHashM?],
                   tchain._hash['strHash'].methodicated?,
                   "((methed._hash['strHash'] #= Hash).methodicated?) => #{tdatum2._hash[:strHashM?].inspect}")
      assert_equal(tchain._hash.strHash,
                   tdatum2._hash['strHash'],
                   '(methed._hash.strHash == raw._hash["strHash"]) => true')
      assert_equal(tchain._hash['strHash'],
                   tdatum2._hash['strHash'],
                   '(methed._hash["strHash"] == raw._hash["strHash"]) => true')

      #
      # Test ._hash['strHash'][:symKey] => String
      #
      assert(! tdatum2._hash['strHash'][:symKey].methodicated?,
             '((raw._hash["strHash"][:symKey] #= String).methodicated?) => false')
      assert_equal(tdatum2._hash['strHash'][:symKeyM?],
                   tchain._hash.symHash.symKey.methodicated?,
                   "((methed._hash.symHash.symKey #= String).methodicated?) => #{tdatum2._hash['strHash'][:symKeyM?].inspect}")
      assert_equal(tdatum2._hash['strHash'][:symKeyM?],
                   tchain._hash['strHash'][:symKey].methodicated?,
                   "((methed._hash['strHash'][:symKey] #= String).methodicated?) => #{tdatum2._hash['strHash'][:symKeyM?].inspect}")
      assert_equal(tchain._hash.symHash.symKey,
                   tdatum2._hash['strHash'][:symKey],
                   '(methed._hash.symHash.symKey == raw._hash["strHash"][:symKey]) => true')
      assert_equal(tchain._hash['strHash'][:symKey],
                   tdatum2._hash['strHash'][:symKey],
                   '(methed._hash["strHash"][:symKey] == raw._hash["strHash"][:symKey]) => true')

      #
      # Test ._hash['strHash']['strKey'] => String
      #
      assert(! tdatum2._hash['strHash']['strKey'].methodicated?,
             '((raw._hash["strHash"]["strKey"] #= String).methodicated?) => false')
      assert_equal(tdatum2._hash['strHash'][:strKeyM?],
                   tchain._hash.symHash.strKey.methodicated?,
                   "((methed._hash.symHash.strKey #= String).methodicated?) => #{tdatum2._hash['strHash'][:strKeyM?].inspect}")
      assert_equal(tdatum2._hash['strHash'][:strKeyM?],
                   tchain._hash['strHash']['strKey'].methodicated?,
                   "((methed._hash['strHash']['strKey'] #= String).methodicated?) => #{tdatum2._hash['strHash'][:strKeyM?].inspect}")
      assert_equal(tchain._hash.symHash.strKey,
                   tdatum2._hash['strHash']['strKey'],
                   '(methed._hash.symHash.strKey == raw._hash["strHash"]["strKey"]) => true')
      assert_equal(tchain._hash['strHash']['strKey'],
                   tdatum2._hash['strHash']['strKey'],
                   '(methed._hash["strHash"]["strKey"] == raw._hash["strHash"]["strKey"]) => false')
    end

  end

end                             # module Tests

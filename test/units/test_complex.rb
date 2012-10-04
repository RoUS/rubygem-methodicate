require('rubygems')
require('test_helper')

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

  end

end                             # module Tests

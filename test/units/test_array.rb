require('rubygems')
require('test_helper')

#
# Test proper access to wrapped arrays.
#

module Tests

  class TestMethodicatedArrays < Test::Unit::TestCase

    #
    # Try methodicating an empty array
    #
    def test_001_empty_array
      tchain = Methodicate.new([])
      assert(tchain.methodicated?,
             'Testing that "methodicate(Array).new" is methodicated')
      assert(tchain.empty?,
             'Testing #empty? passed to methodicated empty array')
    end

    def test_002_append_to_empty_array
      tchain = Methodicate.new([])
      assert(tchain.empty?,
             'Testing #empty? passed to methodicated empty array')
      tchain << 17
      assert(tchain.methodicated?,
             'Testing that "methodicate(Array) <<" remains methodicated')
      assert_equal(17, tchain[0],
                   'Testing #[0] of methodicated 1-element array')
      assert_equal(17, tchain.first,
                   'Testing #first? of methodicated 1-element array')
      assert_equal(1, tchain.size,
                   'Testing #size? of methodicated 1-element array')
      tchain += %w(a b c)
      assert(tchain.methodicated?,
             'Testing that "methodicate(Array) +=" remains methodicated')
      assert_equal(4, tchain.size,
                   'Testing #size? of methodicated 4-element array')
    end

    def test_003_array_slice
      tdata = [1, 2, 3, 4, 5]
      tchain = Methodicate.new(tdata)
      assert(tchain.methodicated?,
             'Testing that "methodicate.new(Array)" is methodicated')
      expected = tdata[1,3]
      tslice = tchain[1,3]
      assert(tslice.methodicated?,
             'Testing that "methodicate(Array)[1,3]" remains methodicated')
      assert_equal(expected.size, tslice.size)
      assert_equal(expected, tslice.unmethodicated)
      assert_equal(expected.inspect, tslice.inspect)
    end

    #
    # Let's try *changing* the wrapped array.
    #
    def test_101_empty_to_sparse
      tchain = Methodicate.new([])
      assert(tchain.methodicated?,
             'Testing that "methodicate.new(Array)" is methodicated')
      tresult = (tchain[9] = 10)
      assert(tchain.methodicated?,
             'Testing that "methodicate([])[n] = n" remains methodicated')
      assert((! tresult.methodicated?),
             'Testing that "methodicate([])[n] = n" return ' +
             'is not methodicated when n is a Fixnum')
      expected = ([ nil ] * 9) + [ 10 ]
      assert_equal(expected.size, tchain.size,
                   'Testing that sparse methodicated array is the right size')
      assert_equal(expected, tchain.unmethodicated,
                   'Testing that wrapped sparse methodicated array ' +
                   'is as expected')
      assert_equal(expected.inspect, tchain.inspect,
                   'Testing that sparse methodicated array displays correctly')
    end

  end

end                             # module Tests

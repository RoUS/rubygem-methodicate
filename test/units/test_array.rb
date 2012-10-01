require('rubygems')
require('test_helper')

#
# Test proper access to wrapped arrays.
#

module Tests

  class TestChainedArrays < Test::Unit::TestCase

    #
    # Try chaining an empty array
    #
    def test_001_empty_array
      tchain = Chained.new([])
      assert(tchain.chained?,
             'Testing that "chained(Array).new" is chained')
      assert(tchain.empty?,
             'Testing #empty? passed to chained empty array')
    end

    def test_002_append_to_empty_array
      tchain = Chained.new([])
      assert(tchain.empty?,
             'Testing #empty? passed to chained empty array')
      tchain << 17
      assert(tchain.chained?,
             'Testing that "chained(Array) <<" remains chained')
      assert_equal(17, tchain[0],
                   'Testing #[0] of chained 1-element array')
      assert_equal(17, tchain.first,
                   'Testing #first? of chained 1-element array')
      assert_equal(1, tchain.size,
                   'Testing #size? of chained 1-element array')
      tchain += %w(a b c)
      assert(tchain.chained?,
             'Testing that "chained(Array) +=" remains chained')
      assert_equal(4, tchain.size,
                   'Testing #size? of chained 4-element array')
    end

    def test_003_array_slice
      tdata = [1, 2, 3, 4, 5]
      tchain = Chained.new(tdata)
      assert(tchain.chained?,
             'Testing that "chained.new(Array)" is chained')
      expected = tdata[1,3]
      tslice = tchain[1,3]
      assert(tslice.chained?,
             'Testing that "chained(Array)[1,3]" remains chained')
      assert_equal(expected.size, tslice.size)
      assert_equal(expected, tslice.unchained)
      assert_equal(expected.inspect, tslice.inspect)
    end

    #
    # Let's try *changing* the wrapped array.
    #
    def test_101_empty_to_sparse
      tchain = Chained.new([])
      assert(tchain.chained?,
             'Testing that "chained.new(Array)" is chained')
      tresult = (tchain[9] = 10)
      assert(tchain.chained?,
             'Testing that "chained([])[n] = n" remains chained')
      assert((! tresult.chained?),
             'Testing that "chained([])[n] = n" return is not chained ' +
             'when n is a Fixnum')
      expected = ([ nil ] * 9) + [ 10 ]
      assert_equal(expected.size, tchain.size,
                   'Testing that sparse chained array is the right size')
      assert_equal(expected, tchain.unchained,
                   'Testing that wrapped sparse chained array is as expected')
      assert_equal(expected.inspect, tchain.inspect,
                   'Testing that sparse chained array displays correctly')
    end

  end

end                             # module Tests

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
      assert(tchain.empty?,
             'Testing #empty? passed to chained empty array')
    end

    def test_002_append_to_empty_array
      tchain = Chained.new([])
      assert(tchain.empty?,
             'Testing #empty? passed to chained empty array')
      tchain << 17
      assert_equal(17, tchain[0],
                   'Testing #[0] of chained 1-element array')
      assert_equal(17, tchain.first,
                   'Testing #first? of chained 1-element array')
      assert_equal(1, tchain.size,
                   'Testing #size? of chained 1-element array')
    end
  end

  def test_003_array_slice
    tdata = [1, 2, 3, 4, 5]
    tchain = Chained.new(tdata)
    expected = tdata[1,3]
    tslice = tchain[1,3]
    assert_equal(expected.size, tslice.size)
    assert_equal(expected, tslice.unchained)
    assert_equal(inspect, tslice.inspect)
  end

end                             # module Tests

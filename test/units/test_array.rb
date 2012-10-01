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

end                             # module Tests

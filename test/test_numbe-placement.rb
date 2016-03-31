require 'test/unit'
require 'number-placement'

class NumberPlacementNeighborsTest < Test::Unit::TestCase
  include NumberPlacement
  def setup
    @n = Neighbors.new
  end

  def test_place
    @n.occupy(0, 0)
    assert_equal 1, @n.cells.size
    assert_equal true, @n.floating[0]
    @n.place(0, 0, 0)
    assert_equal 0, @n.cells.size
    assert_equal false, @n.floating[0]
  end

  def test_place_value_taken
    @n.occupy(0, 0)
    @n.occupy(0, 1)
    @n.place(0, 0, 0)
    assert_raise PlacementError do
      @n.place(0, 1, 0)
    end
  end

  def test_place_cell_taken
    @n.occupy(0, 0)
    @n.place(0, 0, 0)
    assert_raise PlacementError do
      @n.place(0, 0, 1)
    end
  end
end

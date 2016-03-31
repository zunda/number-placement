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

class NumberPlacementBoardTest < Test::Unit::TestCase
  include NumberPlacement
  def setup
    @b = Board.new
    @b[0,0] = 1
    @b[1,0] = 2
    @b[3,1] = 3
    @b[6,2] = 3
  end

  def test_place
    @b[2,0] = 3
    assert_equal 3, @b[2,0]
  end

  def test_place_value_taken
    assert_raise PlacementError do
      @b[2,0] = 1
    end
  end

  def test_plcae_cell_taken
    assert_raise PlacementError do
      @b[0,0] = 3
    end
  end

  def test_firm_candidate
    assert_equal 1, @b.candidates(2,0)[3]
  end

  def test_next_firm
    x, y, v = @b.next_firm(0, 0)
    assert_equal 2, x
    assert_equal 0, y
    assert_equal 3, v
  end
end

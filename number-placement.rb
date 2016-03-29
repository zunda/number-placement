# x, y: location of a cell (0-origin)
# v: value in the cell
module NumberPlacement
  Values = (1..9).to_a
  N = Values.size
  M = Math.sqrt(N).to_i

  class PlacementError < StandardError; end

  # Sub-board that shares set of numbers
  class Neighbors
    attr_reader :floating
    attr_reader :cells

    def initialize
      @floating = Hash.new{|h, k| h[k] =true}
      @cells = Array.new
    end

    def occupy(x, y)
      @cells << [x,y]
    end

    def place(x, y, v)
      unless @floating[v]
        raise PlacementError, "#{v} is already taken"
      end
      unless @cells.delete([x,y])
        raise PlacementError, "#{x},#{y} is already taken"
      end
      @floating[v] = false
    end

    # Array of cells where valuve v can be placed
    def placeable(v, board)
      unless @floating[v]
        return []
      end
      r = @cells
      @cells.each do |x, y|
        board.neighbors(x, y).each do |n|
          next if self === n
          unless n.floating[v]
            r -= n.cells
          end
        end
      end
      return r
    end
  end

  class Board
    # number or `-` for empty cells
    def Board.parse(str)
      b = Board.new
      str.scan(/[\d-]/).each_with_index do |s, i|
        if s =~ /\d/
          y, x = i.divmod(N)
          b[x,y] = Integer(s)
        end
      end
      return b
    end

    def Board.next_cell_from(x, y)
      x += 1
      if x >= N
        x = 0
        y += 1
        if y >= N
          y = 0
        end
      end
      return x, y
    end

    def initialize
      @values = Hash.new
      @neighbors = Hash.new
      @placed = 0

      n = Hash.new
      (0...N).each do |y|
        (0...N).each do |x|
          @values[[x,y]] = nil
          @neighbors[[x,y]] = [
            n[[x/M*M,y/M*M]] ||= Neighbors.new,
            n[[x,"*"]] ||= Neighbors.new,
            n[["*",y]] ||= Neighbors.new,
          ]
          @neighbors[[x,y]].each do |n|
            n.occupy(x, y)
          end
        end
      end
    end

    def complete?
      @placed == N*N
    end

    # Array of Neighbors that share the cell
    def neighbors(x, y)
      @neighbors[[x,y]]
    end

    # Hash: v => number of cells value can be placed
    def candidates(x, y)
      f = Hash.new
      Values.each do |v|
        f[v] = @neighbors[[x,y]].map{|n|
          cs = n.placeable(v, self)
          if cs.include?([x,y])
            cs.size
          else
            0
          end
        }.min
      end
      return f
    end

    # Find location x, y for a firm candidate v, or nil
    def next_firm(x0, y0)
      xc, yc = x0, y0
      begin
        if v = self.candidates(xc, yc).key(1)
          return xc, yc, v
        end
        xc, yc = Board.next_cell_from(xc, yc)
      end while xc != x0 or yc != y0
      return nil
    end

    # value in the cell
    def [](x, y)
      @values[[x,y]]
    end

    # place value in the cell
    def []=(x, y, v)
      @neighbors[[x,y]].each do |n|
        n.place(x, y, v)
      end
      @placed += 1
      @values[[x,y]] = v
    end

    def to_s
      r = ''
      (0...N).each do |y|
        (0...N).each do |x|
          v = @values[[x,y]]
          r << (v ? " #{v} " : ' _ ')
        end
        r << "\n"
      end
      return r
    end
  end
end

include NumberPlacement

str = <<_END
78-----46
--63-----
1---89---
-75---81-
---4-5---
-91---43-
---83---4
-----46--
83-----51
_END

b = Board.parse(str)
puts b
puts

x = y = 0
while !b.complete?
  x, y, v = b.next_firm(x, y)
  if x and y and v
    b[x, y] = v
    puts b
    puts
    x, y = Board.next_cell_from(x, y)
  else
    puts "Solution is not found"
    exit
  end
end

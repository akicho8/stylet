module Stylet2
  class Vector2d
    attr_accessor :x, :y

    def initialize(x = nil, y = nil)
      @x = x || 0
      @y = y || x
    end

    def +(v)
      if v.kind_of?(self.class)
        self.class.new(x + v.x, y + v.y)
      else
        self.class.new(x + v, y + v)
      end
    end

    def -(v)
      if v.kind_of?(self.class)
        self.class.new(x - v.x, y - v.y)
      else
        self.class.new(x - v, y - v)
      end
    end

    def *(v)
      if v.kind_of?(self.class)
        self.class.new(x * v.x, y * v.y)
      else
        self.class.new(x * v, y * v)
      end
    end

    def /(v)
      if v.kind_of?(self.class)
        self.class.new(x / v.x, y / v.y)
      else
        self.class.new(x / v, y / v)
      end
    end

    def fdiv(v)
      if v.kind_of?(self.class)
        self.class.new(x.fdiv(v.x), y.fdiv(v.y))
      else
        self.class.new(x.fdiv(v), y.fdiv(v))
      end
    end

    def to_a
      [x, y]
    end

    def to_s
      "(#{x},#{y})"
    end
  end

  # Vector2d(2, 3) + 1              # => Vector[3, 4]
  # Vector2d(2, 3) - 1              # => Vector[1, 2]
  # Vector2d(2, 3) * Vector2d(2, 3) # => Vector[4, 9]
  # Vector2d(2, 3) / Vector2d(2, 3) # => Vector[1, 1]
end

def Vector2d(*args)
  Stylet2::Vector2d.new(*args)
end

def vec2(*args)
  Stylet2::Vector2d.new(*args)
end

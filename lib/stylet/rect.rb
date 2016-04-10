module Stylet
  class Rect4 < Vector
    attr_accessor :wh

    def self.create(*args)      # DEPRECATE
      new(*args)
    end

    # オブジェクトの中央が原点と考えている場合、
    # 32x32のオブジェクトの16,16が原点になる
    # そのとき表示するのに draw(x-16, y-16, w, h) と書くのが煩雑なので
    # 用意した記憶あり。
    # なので次のように書ける
    # rc = Stylet::Rect4.centered_create(image.w / 2, image.h / 2) # => [-16, -16, 32, 32]
    # draw_rect(rc.add_vector(pos))                                # ← ここが楽になる
    # が、 31 を期待して max_x としたときに 31 ではなく 15 になったりして、混乱するのでこれは廃止したい→これでいい
    def self.centered_create(rx, ry = rx)
      new(-rx, -ry, rx * 2, ry * 2)
    end

    def self.wh(w, h)
      new(0, 0, w, h)
    end

    def self.new2(w, h)
      new(0, 0, w, h)
    end

    def self.new4(x, y, w, h)
      new(x, y, w, h)
    end

    def initialize(x, y, w, h)
      super(x, y)
      @wh = Vector[w, h]
    end

    def w; @wh.x; end
    def h; @wh.y; end

    #--------------------------------------------------------------------------------
    def half_w; w / 2; end
    def half_h; h / 2; end
    def half_wh; [half_w, half_h]; end

    #--------------------------------------------------------------------------------
    def min_x; x;         end
    def max_x; x + w - 1; end
    def min_y; y;         end
    def max_y; y + h - 1; end

    def x_range; min_x..max_x; end
    def y_range; min_y..max_y; end

    #--------------------------------------------------------------------------------
    # 描画と合わせるため小数点があると当たり判定が一致しなくなる
    def min_xi; min_x.to_i; end
    def max_xi; max_x.to_i; end
    def min_yi; min_y.to_i; end
    def max_yi; max_y.to_i; end

    #--------------------------------------------------------------------------------
    def hx; x + w / 2; end
    def hy; y + h / 2; end

    alias width w
    alias height h

    def center
      Vector.new(hx, hy)
    end

    def add_vector(vec)
      Rect4.new(x + vec.x, y + vec.y, w, h)
    end

    def sub_vector(vec)
      Rect4.new(x - vec.x, y - vec.y, w, h)
    end

    def to_vector
      Vector.new(x, y)
    end

    def rect_vector
      Vector.new(w - 1, y - 1)
    end

    def inspect
      "#{super} #{@wh.inspect}"
    end

    def to_a
      [*super, *@wh]
    end
  end

  class Rect2 < Rect4
    def self.[](*args)
      new(*args)
    end

    def initialize(w, h)
      super(0, 0, w, h)
    end
  end
end

if $0 == __FILE__
  p Stylet::Rect4.new(2, 3, 4, 5)
  p Stylet::Rect4.new(2, 3, 4, 5).add_vector(Stylet::Vector.new(6, 7))
  p Stylet::Rect2[1, 2]
end

# メソッド一覧
#
#   Mtx33.create                         ; 単位行列作成
#   Mtx33.translate(x, y)                ; 平行行列作成
#   Mtx33.translate_pref(x, y, m)        ; 平行行列 * m
#   Mtx33.translate_post(x, y, m)        ; m * 平行行列
#   Mtx33.rotate(rot)                    ; 回転行列生成
#   Mtx33.rotate_pref(rot, m)            ; 回転行列 * m
#   Mtx33.rotate_post(rot, m)            ; m * 回転行列
#   Mtx33.scale(x, y)                    ; 拡縮行列
#   Mtx33.scale_pref(x, y, m)            ; 拡縮行列 * m
#   Mtx33.scale_post(x, y, m)            ; m * 拡縮行列
#   Mtx33.transform(*args)               ; 行列 * 行列
#   Mtx33.invert_ortho_normal(m)         ; 正規直交行列の逆行列
#   Mtx33.invert(m)                      ; 逆行列
#   Mtx33.vec2_transform_point(x, y, m)  ; 座標の投影変換
#   Mtx33.vec2_transform_vector(x, y, m) ; ベクトルの投影変換
#
#   _pref, _post は高速化のためだけにあるので transform を使った方がわかりやすい
#
# 参照
#
#   ■Flashゲーム講座＆ASサンプル集【２Ｄアフィン変換を使ってみよう】
#   http://hakuhin.jp/as/mtx_2d.html
#
#   ■2D用の3行3列のマトリックスの関数
#   http://hakuhin.jp/as/matrix_33.html
#
if $0 == __FILE__
  $LOAD_PATH << "../stylet_support/lib"
end

require "stylet/vector"

module Stylet
  class Mtx33
    class << self
      # 単位行列作成
      def create
        {
          a: 1.0, b: 0.0,
          c: 0.0, d: 1.0,
          tx: 0.0, ty: 0.0,
        }
      end

      # 平行行列作成
      def translate(x, y)
        {
          a: 1.0, b: 0.0,
          c: 0.0, d: 1.0,
          tx: x, ty: y,
        }
      end

      # 平行行列 * m
      def translate_pref(x, y, m)
        {
          a: m[:a],
          b: m[:b],
          c: m[:c],
          d: m[:d],
          tx: x * m[:a] + y * m[:c] + m[:tx],
          ty: x * m[:b] + y * m[:d] + m[:ty],
        }
      end

      # m * 平行行列
      def translate_post(x, y, m)
        {
          a: m[:a],
          b: m[:b],
          c: m[:c],
          d: m[:d],
          tx: m[:tx] + x,
          ty: m[:ty] + y,
        }
      end

      # 回転行列生成
      def rotate(rot)
        rad = rot * Math::PI / 180
        cos = Math.cos(rad)
        sin = Math.sin(rad)
        {
          a: cos,  b: sin,
          c: -sin, d: cos,
          tx: 0,  ty: 0,
        }
      end

      # 回転行列 * m
      def rotate_pref(rot, m)
        rad = rot * Math::PI / 180
        cos = Math.cos(rad)
        sin = Math.sin(rad)
        {
          a:  cos * m[:a] + sin * m[:c],
          b:  cos * m[:b] + sin * m[:d],
          c: -sin * m[:a] + cos * m[:c],
          d: -sin * m[:b] + cos * m[:d],
          tx: m[:tx],
          ty: m[:ty],
        }
      end

      # m * 回転行列
      def rotate_post(rot, m)
        rad = rot * Math::PI / 180
        cos = Math.cos(rad)
        sin = Math.sin(rad)
        {
          a: m[:a] * cos + m[:b] * -sin,
          b: m[:a] * sin + m[:b] * cos,
          c: m[:c] * cos + m[:d] * -sin,
          d: m[:c] * sin + m[:d] * cos,
          tx: m[:tx] * cos + m[:ty] * -sin,
          ty: m[:tx] * sin + m[:ty] * cos,
        }
      end

      # 拡縮行列
      def scale(x, y)
        {
          a: x,  b: 0,
          c: 0,  d: y,
          tx: 0, ty: 0,
        }
      end

      # 拡縮行列 * m
      def scale_pref(x, y, m)
        {
          a: x * m[:a],
          b: x * m[:b],
          c: y * m[:c],
          d: y * m[:d],
          tx: m[:tx],
          ty: m[:ty],
        }
      end

      # m * 拡縮行列
      def scale_post(x, y, m)
        {
          a: m[:a] * x,
          b: m[:b] * y,
          c: m[:c] * x,
          d: m[:d] * y,
          tx: m[:tx] * x,
          ty: m[:ty] * y,
        }
      end

      # 行列 * 行列
      def transform(*args)
        args.inject {|m1, m2| __transform(m1, m2) }
      end

      def __transform(m1, m2)
        {
          a: m1[:a] * m2[:a] + m1[:b] * m2[:c],
          b: m1[:a] * m2[:b] + m1[:b] * m2[:d],
          c: m1[:c] * m2[:a] + m1[:d] * m2[:c],
          d: m1[:c] * m2[:b] + m1[:d] * m2[:d],
          tx: m1[:tx] * m2[:a] + m1[:ty] * m2[:c] + m2[:tx],
          ty: m1[:tx] * m2[:b] + m1[:ty] * m2[:d] + m2[:ty],
        }
      end

      # 正規直交行列の逆行列
      def invert_ortho_normal(m)
        {
          a: m[:a],
          b: m[:c],
          c: m[:b],
          d: m[:d],
          tx: -m[:tx] * m[:a] + -m[:ty] * m[:b],
          ty: -m[:tx] * m[:c] + -m[:ty] * m[:d],
        }
      end

      # 逆行列
      def invert(m)
        o = {
          a: 1.0,  b: 0.0,
          c: 0.0,  d: 1.0,
          tx: 0.0, ty: 0.0,
        }

        _01 = m[:b]
        _11 = m[:d]
        _21 = m[:ty]

        if m[:a].nonzero?
          o[:a] /= m[:a]
          _01 /= m[:a]
        end
        _11 -= m[:c] * _01
        o[:c] -= m[:c] * o[:a]
        _21 -= m[:tx] * _01
        o[:tx] -= m[:tx] * o[:a]

        if _11.nonzero?
          o[:c] /= _11
        end
        o[:tx] -= _21 * o[:c]
        o[:a] -= _01 * o[:c]

        _01 = m[:b]
        _11 = m[:d]
        _21 = m[:ty]

        if m[:a].nonzero?
          o[:b] /= m[:a]
          _01 /= m[:a]
        end
        _11 -= m[:c] * _01
        o[:d] -= m[:c] * o[:b]
        _21 -= m[:tx] * _01
        o[:ty] -= m[:tx] * o[:b]

        if _11.nonzero?
          o[:d] /= _11
        end
        o[:ty] -= _21 * o[:d]
        o[:b] -= _01 * o[:d]

        o
      end

      # 座標の投影変換
      def vec2_transform_point(x, y, m)
        Stylet::Vector[
          x * m[:a] + y * m[:c] + m[:tx],
          x * m[:b] + y * m[:d] + m[:ty],
        ]
      end

      # ベクトルの投影変換
      def vec2_transform_vector(x, y, m)
        Stylet::Vector[
          x * m[:a] + y * m[:c],
          x * m[:b] + y * m[:d],
        ]
      end
    end
  end

  if $0 == __FILE__
    # 単位行列作成
    m = Mtx33.create                # => {:a=>1.0, :b=>0.0, :c=>0.0, :d=>1.0, :tx=>0.0, :ty=>0.0}
    # 平行行列作成
    m1 = Mtx33.translate(1, 2)      # => {:a=>1.0, :b=>0.0, :c=>0.0, :d=>1.0, :tx=>1, :ty=>2}
    # 平行行列 * m
    Mtx33.translate_pref(1, 2, m)   # => {:a=>1.0, :b=>0.0, :c=>0.0, :d=>1.0, :tx=>1.0, :ty=>2.0}
    # m * 平行行列
    Mtx33.translate_post(1, 2, m)   # => {:a=>1.0, :b=>0.0, :c=>0.0, :d=>1.0, :tx=>1.0, :ty=>2.0}
    # 回転行列生成
    m2 = Mtx33.rotate(45)           # => {:a=>0.7071067811865476, :b=>0.7071067811865475, :c=>-0.7071067811865475, :d=>0.7071067811865476, :tx=>0, :ty=>0}
    # 回転行列 * m
    Mtx33.rotate_pref(45, m)        # => {:a=>0.7071067811865476, :b=>0.7071067811865475, :c=>-0.7071067811865475, :d=>0.7071067811865476, :tx=>0.0, :ty=>0.0}
    # m * 回転行列
    Mtx33.rotate_post(45, m)        # => {:a=>0.7071067811865476, :b=>0.7071067811865475, :c=>-0.7071067811865475, :d=>0.7071067811865476, :tx=>0.0, :ty=>0.0}
    # 拡縮行列
    Mtx33.scale(1.2, 3.4)           # => {:a=>1.2, :b=>0, :c=>0, :d=>3.4, :tx=>0, :ty=>0}
    # 拡縮行列 * m
    Mtx33.scale_pref(1.2, 3.4, m)   # => {:a=>1.2, :b=>0.0, :c=>0.0, :d=>3.4, :tx=>0.0, :ty=>0.0}
    # m * 拡縮行列
    Mtx33.scale_post(1.2, 3.4, m)   # => {:a=>1.2, :b=>0.0, :c=>0.0, :d=>3.4, :tx=>0.0, :ty=>0.0}
    # 座標の投影変換
    Mtx33.vec2_transform_point(1, 2, m)  # => [1.0, 2.0]
    # ベクトルの投影変換
    Mtx33.vec2_transform_vector(1, 2, m) # => [1.0, 2.0]
    # 行列 * 行列
    Mtx33.transform(m1, m2)         # => {:a=>0.7071067811865476, :b=>0.7071067811865475, :c=>-0.7071067811865475, :d=>0.7071067811865476, :tx=>-0.7071067811865474, :ty=>2.121320343559643}
    # 正規直交行列の逆行列
    Mtx33.invert_ortho_normal(m)    # => {:a=>1.0, :b=>0.0, :c=>0.0, :d=>1.0, :tx=>-0.0, :ty=>-0.0}
    # 逆行列
    Mtx33.invert(m)                 # => {:a=>1.0, :b=>0.0, :c=>0.0, :d=>1.0, :tx=>0.0, :ty=>0.0}

    m = Mtx33.translate(10, 20)
    Mtx33.vec2_transform_point(100, 100, m)  # => [110.0, 120.0]
    m = Mtx33.rotate(1)
    Mtx33.vec2_transform_point(100, 100, m)  # => [98.23952887191078, 101.73001015936748]
    m = Mtx33.scale(1.1, 1.1)
    Mtx33.vec2_transform_point(100, 100, m)  # => [110.00000000000001, 110.00000000000001]

    m1 = Mtx33.translate(10, 20)
    m2 = Mtx33.rotate(1)
    m3 = Mtx33.transform(m1, m2)
    Mtx33.vec2_transform_point(100, 100, m3) # => [107.88895769472902, 121.90148812686814]
  end
end

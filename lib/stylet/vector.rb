# -*- coding: utf-8 -*-
#
# 速度ベクトルの向きを取得するには？
#
#   speed.angle
#
# 速度ベクトルを45度傾けるには？
#
#   speed += Stylet::Vector.sincos(Stylet::Fee.r45) * speed.radius
#
# p0の速度ベクトルをマウスの方向に設定するには？
#
#   speed = Stylet::Vector.sincos(p0.angle_to(base.mouse_vector)) * speed.radius
#
# 円の速度制限をするには？(円が線から飛び出さないようにするときに使う)
#
#   if speed.radius > radius
#     speed = speed.normalize.scale(radius)
#   end
#
# 線分ABの中央の位置を取得するには？
#
#   half_ab = pA + Stylet::Vector.sincos(pA.angle_to(pB)) * (pA.distance(pB) / 2)
#
#   Vector#pos_vector_rate(pA, pB, rate)
#
# 円(p0,r)が点(p1)にめりこんだとき、点から円を押し出すには？
#
#   良い例
#
#     diff = p0 - p1
#     if diff.length < r
#       p0 = p1 + diff.normalize * r
#     end
#
#   悪い例
#
#     if p0.distance(p1) < r
#       p0 = p1 + Stylet::Vector.sincos(p1.angle_to(p0)) * r
#     end
#
module Stylet
  #
  # 二次元座標
  #
  #   単に x y のメンバーがあればいいとき用
  #
  Point = Struct.new(:x, :y)

  #
  # ベクトル
  #
  # 移動制限のつけ方
  #
  #   if vec.length > n
  #     vec.normalize.scale(n)
  #   end
  #
  # 摩擦
  #
  #   vec.scale(0.9)
  #
  class Vector < Point
    def self.random(n = nil)
      x = rand(n)
      if rand(2).zero?
        x = -x
      end
      y = rand(n)
      if rand(2).zero?
        y = -y
      end
      new(x, y)
    end

    ##
    def add(t)
      self.class.new(x + t.x, y + t.y)
    end

    alias :+ add

    def add!(t)
      tap do
        t = add(t)
        self.x, self.y = t.x, t.y
      end
    end

    ##
    def sub(t)
      self.class.new(x - t.x, y - t.y)
    end

    alias :- sub

    def sub!(t)
      tap do
        t = sub(t)
        self.x, self.y = t.x, t.y
      end
    end

    ##
    def scale(s)
      self.class.new(x * s, y * s)
    end

    alias :* scale

    def scale!(s)
      tap do
        s = scale(s)
        self.x, self.y = s.x, s.y
      end
    end

    # 自作の normalize
    # これを使うと内積の計算の0から45度のあたりがおかしくなる
    # def normalize
    #   max = [x.abs, y.abs].max.to_f
    #   # if max.zero?
    #   #   # FIXME: 一般的にはどうなる？
    #   #   return self.class.new(0, 0)
    #   # end
    #   self.class.new(x / max, y / max)
    # end

    def normalize!
      tap do
        v = normalize
        self.x, self.y = v.x, v.y
      end
    end

    # hakuhin.jp/as/collision.html#COLLISION_00 の方法だと x * (1.0 / c) としているけど x.to_f / c でよくないか？
    def normalize
      c = length                # x y のどちらかを最大と考えるのではなく斜線を 1.0 とする
      # if c > 0                # これは ZeroDivisionError を出さないためのものなので 0, 0 のベクトルがなければ不要
      #   c = 1.0 / c
      # end
      self.class.new(Float(x) / c, Float(y) / c)
    end

    # 距離の取得
    #
    #   x.abs ** 2 のように書いてたけど必要なかった
    #   次のようにマイナスでも二回掛けると必ず正になるので
    #     -2 * -2 = 4
    #      2 *  2 = 4
    #
    #   当たり判定を次のように行なっている場合、
    #     sx = mx - ax
    #     sy = my - ay
    #     if sqrt(sx * sx + sy * sy) < r
    #     end
    #
    #   次のように sqrt を外すことができる
    #     if (sx * sx + sy * sy) < (r ** 2)
    #     end
    #
    def length
      Math.sqrt(x ** 2 + y ** 2)
    end

    alias radius length

    #
    # 反対方向のベクトルを返す
    #
    def __negative
      self.class.new(-x, -y)
    end

    # 反射ベクトルの取得
    #
    #   s: スピードベクトル
    #   n: 法線ベクトル
    #
    #   定石
    #     速度ベクトル += 速度ベクトル.reflect(法線ベクトル).scale(反射係数)
    #     @speed += @speed.reflect(@normal).scale(0.5)
    #
    #   反射係数
    #     ×1.5: 謎の力によってありえない反射をする
    #     ◎1.0: 摩擦なし(標準)
    #     ◎0.8: 少しす滑る
    #     ○0.6: かなり滑ってほんの少しだけ反射する
    #     ○0.5: 線に沿って滑る
    #     ×0.4: 線にわずかにめり込んだまま滑る
    #     ○0.0: 線に沿って滑る(突き抜けるかと思ったけど滑る)
    #
    #   hakuhin.jp/as/collide.html#COLLIDE_02 の方法だと x + t * n.x * 2.0 * 0.8 と一気に書いていたけど
    #   メソッド化するときには分解した方がわかりやすそうなのでこうした。
    #
    def reflect(n)
      t = -(n.x * x + n.y * y) / (n.x ** 2 + n.y ** 2)
      self.class.new(
        # x + t * n.x * 2.0,
        # y + t * n.y * 2.0
        # x + t * n.x * 2.0 * rate,
        # y + t * n.y * 2.0 * rate
        t * n.x * 2.0,
        t * n.y * 2.0
        )
    end

    # function Vec3dSlide(spd,nor){
    #     var t = -(nor.x * spd.x + nor.y * spd.y)/
    # (nor.x * nor.x + nor.y * nor.y);
    #     return {
    #         x : spd.x + t * nor.x,
    #         y : spd.y + t * nor.y
    #     };
    # }

    #
    #    p: 現在地点
    #    s: スピードベクトル
    #    a: 線の片方
    #    n: 法線ベクトル
    #
    # としたら何倍したら線にぶつかるか
    def self.collision_scale(p, s, a, n)
      d = -(a.x * n.x + a.y * n.y)
      -(n.x * p.x + n.y * p.y + d) / (n.x * s.x + n.y * s.y)
    end

    # 内積
    #
    #   2つの単位ベクトルの平行の度合いを表わす
    #   ・ベクトルは正規化しておくこと
    #   ・引数の順序は関係なし
    #
    #   a が右向きのとき b のそれぞれの向きによって以下の値になる
    #              0.0
    #         -0.5  │   0.5
    #               │
    #      -1.0 ──＋── 1.0 (a)
    #               │
    #         -0.5  │   0.5
    #              0.0
    #
    #   これからわかること
    #   1. ←← or →→ 正 (0.0 < v)   お互いだいたい同じ方向を向いている
    #   2. →←         負 (v   < 0.0) お互いだいたい逆の方向を向いている
    #   3. →↓ →↑    零 (0.0)       お互いが直角の関係
    #
    def self.inner_product(a, b)
      a = a.normalize
      b = b.normalize
      a.x * b.x + a.y * b.y
    end

    def inner_product(t)
      self.class.send(__method__, self, t)
    end

    # 法線ベクトルの取得(方法1)
    # どう見ても遅い
    def slowly_normal(t)
      a = angle(t) + Stylet::Fee.r90
      self.class.new(Stylet::Fee.cos(a), Stylet::Fee.sin(a))
    end

    # 法線ベクトルの取得(方法2)
    def normal(t)
      dx = t.x - x
      dy = t.y - y
      self.class.new(-dy, dx)
    end

    # 方向ベクトル
    #
    #   これを使うと次のように簡単に書ける
    #   cursor.x += Stylet::Fee.cos(dir) * speed
    #   cursor.y += Stylet::Fee.sin(dir) * speed
    #     ↓
    #   cursor += Stylet::Fee.sincos(dir) * speed
    #
    def self.sincos(a)
      new(Stylet::Fee.cos(a), Stylet::Fee.sin(a))
    end

    # def sincos(t)
    #   a = angel(t)
    #   self.class.new(Stylet::Fee.cos(a), Stylet::Fee.sin(a))
    # end

    #
    # 相手との距離を取得
    #
    #   三平方の定理
    #
    #             p2
    #        c     b
    #     p0   a  p1
    #
    #     c = sqrt(a * a + b * b)
    #
    def distance(target)
      dx = x - target.x
      dy = y - target.y
      Math.sqrt(dx ** 2 + dy ** 2)
    rescue Errno::EDOM => error
      p [self, target]
      raise error
    end

    #
    # 相手の方向を取得
    #
    #   Math.atan2(y, x) * 180 / Math.PI
    #
    def angle_to(target)
      Stylet::Fee.angle(x, y, target.x, target.y)
    end

    #
    # ベクトルから角度に変換
    #
    def angle
      Stylet::Fee.angle(0, 0, x, y)
    end

    #
    # 線分 A B の距離 1.0 をしたとき途中の位置ベクトルを取得
    #
    def self.pos_vector_rate(a, b, rate)
      a + Stylet::Vector.sincos(a.angle_to(b)) * (a.distance(b) * rate)
    end
  end
end

if $0 == __FILE__
  p0 = Stylet::Vector.new(1, 1)
  p1 = Stylet::Vector.new(1, 1)
  p(p0 == p1)
  p p0
  p p0 + p1
  p p0.add(p1)
  p p0
  p p0.add!(p1)
  p p0

  p0 = Stylet::Vector.new(0, 0)
  p p0.normalize
end
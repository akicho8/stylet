#
# ブロックとブロックの当たり判定
#
require_relative "helper"

class App < Stylet::Base
  include Helper::CursorWithObjectCollection

  setup do
    self.title = "ブロックとブロックの当たり判定"

    # A
    @pA = srect.center.clone                              # 点
    @rA = Stylet::Rect4.centered_create(40, 40)                # 大きさ
    @sA = vec2.angle_at(Stylet::Magic.degree(180 + 90)) # 速度

    # B
    @pB = srect.center.clone                        # 点
    @rB = Stylet::Rect4.centered_create(100, 60)         # 大きさ
    @sB = vec2.angle_at(Stylet::Magic.degree(45)) # 速度

    @speed = 100    # 速度ベクトル 1.0 を画面上では何ドットで表わすか？
    @max_length = 1 # どれだけめり込んだら当たったとみなすか？

    cursor.vertex = 3
  end

  update do
    # 操作
    begin
      # AとBで速度ベクトルの反映
      @pA += @sA.scale(button.btA.repeat_0or1) + @sA.scale(-button.btB.repeat_0or1)
      @pB += @sB.scale(button.btA.repeat_0or1) + @sB.scale(-button.btB.repeat_0or1)

      # Cボタンおしっぱなし + マウスで自機位置移動
      if button.btC.press?
        @pA = cursor.point.clone
      end

      # Dボタンおしっぱなし + マウスで自機角度変更
      if button.btD.press?
        if cursor.point != @pA
          @sA = (cursor.point - @pA).normalize * @sA.magnitude
        end
      end
    end

    # それぞれを実座標に変換
    @tA = @rA.vector_add(@pA)
    @tB = @rB.vector_add(@pB)

    # めりこみサイズを4辺について調べる
    _l = @tA.max_xi - @tB.min_xi # A|B
    _r = @tB.max_xi - @tA.min_xi # B|A
    _u = @tA.max_yi - @tB.min_yi # A/B
    _d = @tB.max_yi - @tA.min_yi # B/A

    # 当たり判定
    @collision = false
    if true &&
        _l >= @max_length && # A|B
        _r >= @max_length && # B|A
        _u >= @max_length && # A/B
        _d >= @max_length && # B/A
        true

      # __fill_rect2(@tA)

      faces = {_l => :l, _r => :r, _u => :u, _d => :d}
      vputs faces.sort.inspect

      face = faces.sort.first.last
      diff = case face
             when :r then vec2[_r + 1, 0]
             when :d then vec2[0, _d + 1]
             when :u then vec2[0, -(_u + 1)]
             when :l then vec2[-(_l + 1), 0]
             end

      @collision = true
      @pA += diff

      # これも一旦ずらして、反射を入れる

      # 両方はねかえる
      # @pA += diff / 2
      # @pB -= diff / 2

      # @tA = @tA.vector_add(diff.scale(0.99))
      # @pB -= diff.scale(0.01)

      # # 実座標から大きさベクトルを引くと中心点になる
      # @pA = @tA.to_vector - @rA.to_vector

      @tA = @rA.vector_add(@pA)
      @tB = @rB.vector_add(@pB)
    end

    # screen.fill_rect(10, 10, 0, 0, [255, 255, 255])
    # draw_rect(@tA, :fill => @collision)

    draw_rect(@tA, :fill => @collision)

    if button.btC.press? && @collision
      # ゴーストの表示
      draw_rect(@rA.vector_add(cursor.point))
    end

    vputs "A", :vector => @pA
    vputs "A: #{@tA}"
    draw_vector(@sA.scale(@speed), :origin => @pA, :label => @sA.magnitude)

    draw_rect(@rB.vector_add(@pB))
    vputs "B", :vector => @pB
    vputs "B: #{@rB}"
    draw_vector(@sB.scale(@speed), :origin => @pB, :label => @sB.magnitude)
  end

  run
end

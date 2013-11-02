# -*- coding: utf-8 -*-

require_relative "helper"

class MovablePoint
  attr_reader :pos

  def initialize(unit, pos)
    @unit = unit
    @pos = pos.clone

    @win = @unit.win
    @dragging = false # ドラッグ中か？
    @radius = 16      # 当り判定の大きさ
  end

  def update
    # ここはモジュール化できる
    begin
      unless @dragging
        if @win.button.btA.trigger?
          if Stylet::CollisionSupport.squire_collision?(@pos, @win.mouse.point, :radius => 8)
            # 他の奴がアクティブじゃなかったときだけ自分を有効にできる
            # これを入れないと同時に複数のポイントをドラッグできてしまう
            unless @unit.dragging_current
              @dragging = true
              @unit.dragging_current = self
            end
          end
        end
      else
        unless @win.button.btA.press?
          @dragging = false
          @unit.dragging_current = nil
        end
      end

      if self == @unit.dragging_current
        @pos = @win.mouse.point.clone
      end
    end

    if self == @unit.dragging_current
      @win.draw_circle(@pos, :radius => @radius, :vertex => 32)
    else
      @win.draw_circle(@pos, :radius => 2)
    end
  end
end

module BezierUnitBase
  attr_accessor :dragging_current
  attr_accessor :win

  def initialize(win)
    @win = win

    @cpoints = []           # ポイント配列
    @dragging_current = nil # 現在どのポイントをドラッグしているか？
    @line_count = 50       # 軌跡確認用弧線の構成ライン数初期値(確認用)

    setup
    update_title
  end

  def setup
    raise NotImplementedError, "#{__method__} is not implemented"
  end

  def update
    # ポイント位置のドラッグと描画
    @cpoints.each{|e|e.update}

    if false
      # 構成ライン数の減算
      @line_count += @win.button.btC.repeat
      @line_count -= @win.button.btD.repeat
      @line_count = [2, @line_count].max
      @win.vputs "@line_count = #{@line_count}"
    end

    # ドラッグ中またはAボタンを押したときは詳細表示
    if @dragging_current || @win.button.btA.press?
      # 弧線の描画
      mpoints_all.each_cons(2) do |p0, p1|
        @win.draw_line(p0, p1)
      end
    end

    # ポイントの番号の表示
    @cpoints.each_with_index{|e, i|@win.vputs(i, :vector => e.pos)}

    unless @cpoints.empty?
      # 物体をいったりきたりさせる
      if false
        # ○の表示
        pos = 0.5 + (Stylet::Fee.sin(@win.count / 256.0) * 0.5)
        xy = __bezier_point(pos)
        @win.draw_circle(xy, :radius => 64, :vertex => 32)
        @win.vputs(pos)
      else
        # △の表示で進んでいる方向を頂点にする
        pos0 = 0.5 + (Stylet::Fee.sin(1.0 / 256 * @win.count) * 0.5)      # 現在の位置(0.0〜1.0)
        pos1 = 0.5 + (Stylet::Fee.sin(1.0 / 256 * @win.count.next) * 0.5) # 未来の位置(0.0〜1.0)
        p0 = __bezier_point(pos0)                                         # 現在の座標
        p1 = __bezier_point(pos1)                                         # 未来の座標
        @win.draw_triangle(p0, :angle => p0.angle_to(p1), :radius => 64)  # 三角の頂点を未来への向きに設定して三角描画
      end

      if @win.button.btB.trigger?
        # 最後に制御点の追加
        @cpoints = [
          @cpoints.first(@cpoints.size - 1),
          MovablePoint.new(self, @cpoints.last.pos + Stylet::Vector.new(-30, 0)),
          @cpoints.last,
        ].flatten
        update_title
      end
      if @win.button.btC.trigger?
        # 最後の制御点を削除
        if @cpoints.size >= 2
          @cpoints[-2] = nil
          @cpoints.compact!
          update_title
        end
      end
      @win.vputs "#{@cpoints.size} (B+ C-)"

      # begin
      #   # 垂直の線
      #   p0 = @win.rect.center + Stylet::Vector.new(0,  @win.rect.h / 3)
      #   p1 = @win.rect.center + Stylet::Vector.new(0, -@win.rect.h / 3)
      # 
      #   # l = a*(x3-2*x2+x1)+b*(y3-2*y2+y1)
      #   # m = 2*(a*(x2-x1)+b*(y2-y1))
      #   # n = a*x1+b*y1+c
      # 
      #   # l = a*(x3-2*x2+x1)+b*(y3-2*y2+y1)
      #   # m = 2*(a*(x2-x1)+b*(y2-y1))
      #   # n = a*x1+b*y1+c
      # 
      #   @win.draw_line(p0, p1)
      # end
    end
  end

  def update_title
    @win.title = "#{@cpoints.size - 1}次ベジェ曲線"
  end

  def mpoints_all
    @line_count.next.times.collect{|i|
      __bezier_point(1.0 / @line_count * i)
    }
  end

  def __bezier_point(*args)
    bezier_point(@cpoints.collect{|e|e.pos}, *args)
  end

  def bezier_point(*args)
    raise NotImplementedError, "#{__method__} is not implemented"
  end
end

class App < Stylet::Base
  include Helper::CursorWithObjectCollection

  def before_run
    super if defined? super
    @objects << BezierUnit.new(self)
  end
end

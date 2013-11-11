# -*- coding: utf-8 -*-
#
# 内積
#
require_relative "helper"

class Scene
  def initialize(win)
    @win = win
    @vA = Stylet::Vector.angle_at(Stylet::Fee.clock(3)).scale(100)
    @vB = Stylet::Vector.angle_at(Stylet::Fee.clock(0)).scale(100)
  end

  def update
    v = (@win.cursor.point - @win.rect.center)
    if @win.button.btA.press?
      @vA = v
    else
      @vB = v
    end

    # Bを動かしているときにはAをnormalizeした方がわかりやすい
    inner_product = Stylet::Vector.inner_product(@vA.normalize, @vB)
    outer_product = Stylet::Vector.outer_product(@vA.normalize, @vB)

    @win.vputs "内積(横): #{inner_product.round(2)}"
    @win.vputs "外積(縦): #{outer_product.round(2)}"

    vC = @vA.normalize * inner_product
    vD = @vA.normalize.rotate(Stylet::Fee.r90) * outer_product
    @win.draw_vector(vC, :origin => @win.rect.center, :color => "orange")
    @win.draw_vector(vD, :origin => vC + @win.rect.center, :color => "orange")

    # ベクトル可視化
    @win.draw_vector(@vA, :origin => @win.rect.center, :label => "A #{@vA.round(2)}")
    @win.draw_vector(@vB, :origin => @win.rect.center, :label => "B #{@vB.round(2)}")
  end
end

class App < Stylet::Base
  include Helper::CursorWithObjectCollection

  def before_run
    super if defined? super
    @objects << Scene.new(self)
  end
end

App.run

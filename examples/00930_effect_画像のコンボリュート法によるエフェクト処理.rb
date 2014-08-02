# -*- coding: utf-8 -*-
# 参考
# 画像のコンボリュート法によるブラー処理(dinop.com)
# http://www.dinop.com/vc/image_convolute_blur.html

require_relative "helper"
require "matrix"

Stylet.configure do |config|
  config.screen_size = [640, 480]
  config.production = true
end

class App < Stylet::Base
  include Helper::Cursor

  setup do
    SDL::Mouse.hide
    # cursor.display = false

    @around = [
      [-1,-1],[0,-1],[1,-1],
      [-1,0],[0,0],[1,0],
      [-1,1],[0,1],[1,1],
    ]

    @cell = 8

    @index = 0
    load_image
    effect_set
  end

  update do
    if button.btB.trigger? || button.btC.trigger? || button.btD.trigger?
      @index += -button.btB.repeat + button.btC.repeat
      load_image
      effect_set
    end
    if button.btA.trigger? || count == 0
      (screen.h / @cell).times.each do |y|
        (screen.w / @cell).times.each do |x|
          color = Vector[0, 0, 0]
          @around.each.with_index do |v, i|
            vv = Vector[x, y] + Vector[*v]
            color += Vector[*screen.format.get_rgb(screen[*(vv * @cell)])] * @current[:weights][i]
          end
          color /= @total_weight
          color = color.collect do |v|
            if v < 0
              0
            elsif v > 255
              255
            else
              v
            end
          end
          screen.fill_rect(x * @cell, y * @cell, @cell, @cell, color.to_a)
        end
      end
    end
    vputs "A:実行 B:NEXT C:PREV"
    vputs "#{@index}:#{@current[:name]}"
  end

  def background_clear
  end

  def effect_set
    @effects = [
      {
        :name => "ブラー",
        :weights => [
          1, 2, 1,
          2, 3, 2,
          1, 2, 1,
        ],
      },
      {
        :name => "ぼかし",
        :weights => [
          1, 1, 1,
          1, 1, 1,
          1, 1, 1,
        ],
      },
      {
        :name => "シャープ",
        :weights => [
          0, -3, 0,
          -3, 24, -3,
          0, -3, 0,
        ],
      },
      {
        :name => "エンボス",
        :weights => [
          -4, -2, 0,
          -2, 2, -2,
          0, 2, 4,
        ],
      },
      {
        :name => "なし",
        :weights => [
          0, 0, 0,
          0, 1, 0,
          0, 0, 0,
        ],
      },
    ]
    @current = @effects[@index.modulo(@effects.size)]
    @total_weight = @current[:weights].reduce(0, :+).abs.to_f
  end

  def load_image
    s = SDL::Surface.load("assets/love_live.png")
    image = s.display_format
    screen.put(image, 0, 0)
  end

  # def screen_reset
  #   screen.h.times.each{|y|
  #     screen.w.times.each{|x|
  #       screen[x, y] = screen.format.map_rgb(*3.times.collect{rand(256)})
  #     }
  #   }
  # end

  run
end

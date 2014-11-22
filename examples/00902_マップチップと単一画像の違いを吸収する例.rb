# -*- coding: utf-8 -*-
require_relative "helper"

Stylet::Palette[:background] = [107, 140, 255]
Stylet::Palette[:font]       = [0, 0, 0]

module Sprity
  class << self
    def processing(surface, params)
      if params[:rect]
        surface = surface.copy_rect(*params[:rect])
      end
      if params[:transform]
        surface = transform(surface, params[:transform])
      end
      surface
    end

    def load_file(filename)
      surface = SDL::Surface.load(filename)
      surface.set_color_key(SDL::SRCCOLORKEY, 0)
      surface.display_format
    end

    private

    def transform(surface, params)
      w, h = params[:wh] || [surface.w, surface.h]
      s = surface.transform_surface(
        0,                      # bg_color
        params[:angle] || 0,    # 角度
        w.to_f / surface.w,     # x倍率
        h.to_f / surface.h,     # y倍率
        0)
      s.set_color_key(SDL::SRCCOLORKEY, 0)
      s.display_format
    end
  end

  class ImageFile
    include StaticRecord
    static_record [
      {:key => :castle2, :filename => "../assets/images/dlmap/castle2.png"},
    ]

    def surface
      @surface ||= Sprity.load_file(@attributes[:filename])
    end
  end

  class Sprite
    include Stylet::Delegators

    # 1. filename に対応する画像を読み込む。共有画像を指す場合はシンボルにする。
    # 2. rect があればそのサイズで切り取る
    # 3. transform があればその指定で拡縮回転
    include StaticRecord
    static_record [
      {:key => :kusa,   :filename => :castle2, :rect => [16 * 7,  16 * 0, 16, 16]},
      {:key => :kusa_l, :filename => :castle2, :rect => [16 * 7,  16 * 0, 16, 16], :transform => {:wh => [32, 32]}},
      {:key => :hana,   :filename => :castle2, :rect => [16 * 28, 16 * 1, 16, 16], :transform => {:wh => [32, 32], :angle => 45}},
      {:key => :mario,  :filename => "assets/mario.png"},
      {:key => :mario2, :filename => "assets/mario.png", :transform => {:wh => [64, 64], :angle => 45}},
    ]

    def swh
      @swh ||= vec2[surface.w, surface.h]
    end

    def surface
      @surface ||= _surface
    end

    private

    def _surface
      key = @attributes[:filename]
      if Symbol === key
        s = ImageFile[key].surface
      else
        s = Sprity.load_file(key)
      end
      Sprity.processing(s, @attributes)
    end
  end
end

class App < Stylet::Base
  include Helper::Cursor

  update do
    draw_texture(:mario2, cursor.point)

    if true
      xy = srect.center / 4
      Sprity::Sprite.each do |info|
        draw_texture(info.key, xy)
        xy.y += info.swh.y
      end
    end
  end

  def draw_texture(key, xy)
    sprite = Sprity::Sprite[key]
    screen.put(sprite.surface, *xy)
    draw_rect4(*xy, *sprite.swh)
    vputs "#{key}: #{sprite.swh.to_a}", :vector => xy + [sprite.swh.x, 0]
  end

  run
end

require_relative "helper"
require "stylet/contrib/sprity" # ../lib/stylet/contrib/sprity.rb

Stylet::Palette[:background] = [107, 140, 255]
Stylet::Palette[:font]       = [0, 0, 0]

if true
  Stylet::Sprity.reset_cache_all

  Stylet::Sprity::ImageFile.static_record_list_set [
    {:key => :castle2, :filename => "../assets/images/dlmap/castle2.png", :mask => true},
  ]

  Stylet::Sprity::Sprite.static_record_list_set [
    {:key => :kusa,   :filename => :castle2, :cliping => [16 * 7,  16 * 0, 16, 16]},
    {:key => :kusa_l, :filename => :castle2, :cliping => [16 * 7,  16 * 0, 16, 16], :transform => {:wh => [32, 32], :mask => true}},
    {:key => :hana,   :filename => :castle2, :cliping => [16 * 28, 16 * 1, 16, 16], :transform => {:wh => [32, 32], :angle => 45, :mask => true}},
    {:key => :mario,  :filename => "assets/mario.png", :mask => true},
    {:key => :mario2, :filename => "assets/mario.png", :transform => {:wh => [64, 64], :angle => 45, :mask => true}},
    {:key => :mario3, :filename => "assets/mario.png", :transform => {:mix => {:rgb => [0, 0, 255], :alpha => 128}}},
  ]
end

class App < Stylet::Base
  include Helper::Cursor

  update do
    draw_texture(:mario2, cursor.point)

    if true
      xy = srect.center / 4
      Stylet::Sprity::Sprite.each do |info|
        draw_texture(info.key, xy)
        xy.y += info.swh.y
      end
    end
  end

  def draw_texture(key, xy)
    sprite = Stylet::Sprity::Sprite[key]
    screen.put(sprite.surface, *xy)
    draw_rect4(*xy, *sprite.swh)
    vputs "#{key}: #{sprite.swh.to_a}", :vector => xy + [sprite.swh.x, 0]
  end

  run
end

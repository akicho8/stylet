# マップチップと単一画像の違いを吸収してキャラクタを表示する
#
# ▼スプライトの登録と描画
#
#   Sprity::ImageFile.static_record_list_set [
#     {:key => :foo, :filename => "assets/images/foo.png"},
#   ]
#
#   screen.put(Sprity::Sprite[:foo].surface, 0, 0)
#
# ▼内部で保持している surface をすべて解放
#
#   Stylet::Sprity.surface_destroy_all
#
# ▼ :filename の指定がシンボルなら ImageFile から取得し、文字列ならそのパスから読み出す
#
#   {:key => :mario, :filename => :maptip}           ← 主に一つの画像にキャラがたくさん入っている時用でサーフェイスを共有する
#   {:key => :mario, :filename => "background.png"}  ← 一つの画像とする
#
# ▼マップチップから指定の部分を刳り貫く 16 x 16 と考えて 2, 3 の部分から 16 x 16 で刳り貫く
#
#   {:cliping => [16 * 2, 16 * 3, 16, 16]}
#
# ▼マップチップから指定の部分を刳り貫いたあと 32 x 32 に拡大して、余白を抜き色にする
#
#   {:cliping => [...], :transform => {:wh => [32, 32], :mask => true}}
#
# ▼回転する
#
#   {:transform => {:angle => 45}}
#
# ▼ ([0, 0, 255] の色を 0.5 だけ掛け合わせる (mixの値を配列にすると実行を繰り返す)
#
#   {:transform => {:mix => {:rgb => [0, 0, 255], :alpha => 128}}}
#

module Stylet
  module Sprity
    class << self
      def surface_destroy_all
        [ImageFile, Sprite].each(&:surface_destroy_all)
      end

      def processing(surface, params)
        if params[:cliping]
          surface = surface.copy_rect(*params[:cliping])
        end
        if params[:transform]
          surface = transform(surface, params[:transform])
        end
        surface
      end

      def load_file(filename, mask: false)
        surface = SDL::Surface.load(filename)
        if mask
          surface.set_color_key(SDL::SRCCOLORKEY, 0)
        end
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
          0)                      # flags

        Array.wrap(params[:mix]).each do |mix|
          s.draw_rect(0, 0, s.w, s.h, mix[:rgb], true, mix[:alpha])
        end

        if params[:mask]
          s.set_color_key(SDL::SRCCOLORKEY, 0)
        end

        s.display_format
      end
    end

    module SurfaceShare
      extend ActiveSupport::Concern

      included do
      end

      class_methods do
        def surface_destroy_all
          each(&:surface_destroy)
        end
      end

      def surface_destroy
        if @surface
          unless @surface.destroyed?
            @surface.destroy
          end
          @surface = nil
        end
      end

      def surface
        @surface ||= _surface
      end
    end

    class ImageFile
      include SurfaceShare

      include StaticRecord
      static_record []

      private

      def _surface
        Sprity.load_file(@attributes[:filename], mask: @attributes[:mask])
      end
    end

    class Sprite
      include SurfaceShare

      include Stylet::Delegators

      include StaticRecord
      static_record []

      def swh
        @swh ||= vec2[surface.w, surface.h]
      end

      private

      def _surface
        key = @attributes[:filename]
        if key.kind_of? Symbol
          s = ImageFile[key].surface
        else
          s = Sprity.load_file(key, mask: @attributes[:mask])
        end
        Sprity.processing(s, @attributes)
      end
    end
  end
end

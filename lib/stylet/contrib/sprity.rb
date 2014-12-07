# -*- coding: utf-8 -*-
module Stylet
  module Sprity
    class << self
      def reset_cache_all
        [ImageFile, Sprite].each(&:reset_cache_all)
      end

      def processing(surface, params)
        if params[:rect]
          surface = surface.copy_rect(*params[:rect])
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

        if mix = params[:mix]
          s.draw_rect(0, 0, s.w, s.h, mix[:rgb], true, mix[:alpha])
        end

        if params[:mask]
          s.set_color_key(SDL::SRCCOLORKEY, 0)
        end

        s.display_format
      end
    end

    class ImageFile
      include StaticRecord
      static_record []

      def surface
        @surface ||= Sprity.load_file(@attributes[:filename], mask: @attributes[:mask])
      end

      def self.reset_cache_all
        each(&:reset_cache)
      end

      def reset_cache
        if @surface
          unless @surface.destroyed?
            @surface.destroy
          end
          @surface = nil
        end
      end
    end

    class Sprite
      include Stylet::Delegators

      include StaticRecord
      static_record []

      def swh
        @swh ||= vec2[surface.w, surface.h]
      end

      def surface
        @surface ||= _surface
      end

      def self.reset_cache_all
        each(&:reset_cache)
      end

      def reset_cache
        if @surface
          unless @surface.destroyed?
            @surface.destroy
          end
          @surface = nil
        end
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

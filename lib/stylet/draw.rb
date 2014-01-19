# -*- coding: utf-8 -*-
#
# SDL描画関連
#

module Stylet
  module Draw
    attr_reader :count, :check_fps, :sdl_event, :rect, :screen
    attr_accessor :title

    def initialize
      super
      @init_code |= SDL::INIT_VIDEO
    end

    def sdl_initialize
      super

      @count = 0
      @check_fps = CheckFPS.new

      options = Stylet.config.screen_options
      if Stylet.config.full_screen
        options |= SDL::FULLSCREEN
      end
      options |= SDL::HWACCEL
      @screen ||= SDL::Screen.open(*Stylet.config.screen_size, Stylet.config.color_depth, options)
      @rect = Rect2.new(@screen.w, @screen.h)

      @vi = SDL::Screen.info
      @vi.class.instance_methods(false).each{|var|
        p "#{var}: #{@vi.send(var)}"
      }

      if @title
        self.title = title
      end

      unless @backgroud_image
        if Stylet.config.background_image
          file = Pathname(Stylet.config.background_image)
          unless file.exist?
            file = Pathname("#{__dir__}/assets/#{file}")
          end
          if file.exist?
            bin = SDL::Surface.load(file.to_s) # SDL.image があれば BMP 以外をロードできる
            if false
              # これを設定すると黒色は透明色になって描画されない
              bin.set_color_key(SDL::SRCCOLORKEY, 0)
            end
            @backgroud_image = bin.display_format
          end
        end
      end

      # background_clear

      # SGE関係でウィンドウを自動ロックさせる(これは必要なのか？)
      if SDL.respond_to?(:auto_lock)
        SDL.auto_lock = true
      end

      p ["#{__FILE__}:#{__LINE__}", __method__]
    end

    # ハードウェアがダブルバッファ対応の場合、flipで自動的にVSYNCを待って切り替えるため
    # ハードウェアのフレーム数(60FPS)以上にはならないことに注意
    def after_draw
      super
      @screen.flip
      @count += 1
    end

    def after_run
      super
      if @screen
        @screen.destroy
        @screen = nil
      end
      if @backgroud_image
        @backgroud_image.destroy
        @backgroud_image = nil
      end
    end

    def title=(title)
      @title = title
      if @screen
        SDL::WM::set_caption(@title.to_s, @title.to_s)
      end
    end

    def polling
      super
      if @sdl_event = SDL::Event.poll
        case @sdl_event
        when SDL::Event::Quit # Window の [x] が押されたとき
          throw :exit, :break
        when SDL::Event::KeyDown
          if @sdl_event.sym == SDL::Key::ESCAPE || @sdl_event.sym == SDL::Key::Q
            throw :exit, :break
          end
        end
      end
    end

    def key_down?(key_sym)
      if @sdl_event.kind_of? SDL::Event::KeyDown
        @sdl_event.sym == key_sym
      end
    end

    def __draw_line(x0, y0, x1, y1, color)
      @screen.draw_line(x0, y0, x1, y1, Palette[color])
    end

    #
    # draw_rect の場合、デフォルトだと幅+1ドット描画されるため -1 してある
    #
    def __draw_rect(x, y, w, h, options = {})
      options = {
        :color => "foreground",
      }.merge(options)
      raise "w, h は正を指定するように" if w < 0 || h < 0
      return if w.zero? || h.zero?
      if options[:fill]
        method = :fill_rect
        w = w.abs
        h = h.abs
      else
        method = :draw_rect
        w = w.abs - 1
        h = h.abs - 1
      end
      @screen.send(method, x, y, w, h, Palette[options[:color]])
    end

    def draw_line(p0, p1, options = {})
      options = {
        :color => "foreground",
      }.merge(options)
      @screen.draw_line(p0.x, p0.y, p1.x, p1.y, Palette[options[:color]])
    rescue RangeError => error
      # warn [p0, p1].inspect
      # raise error
    end

    def draw_dot(p0, options = {})
      draw_line(p0, p0, options)
    end

    def draw_rect(rect, options = {})
      __draw_rect(rect.x, rect.y, rect.w, rect.h, options)
    end

    def save_bmp(fname)
      @screen.save_bmp(fname)
    end

    def system_line
      "#{@count} #{@check_fps.fps} FPS"
    end

    def before_update
      super
      return if Stylet.production
      @check_fps.update
      vputs(system_line)
    end

    private

    def background_clear
      if @backgroud_image
        SDL::Surface.blit(@backgroud_image, @rect.x, @rect.y, @rect.w, @rect.h, @screen, 0, 0)
      else
        draw_rect(@rect, :color => "background", :fill => true)
      end
    end
  end
end

if $0 == __FILE__
  require_relative "../stylet"
  Stylet.run
end

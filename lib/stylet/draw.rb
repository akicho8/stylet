# -*- coding: utf-8 -*-
#
# SDL描画関連
#

module Stylet
  module Draw
    attr_reader :count, :check_fps, :sdl_event, :rect, :screen, :screen_active
    attr_accessor :title

    def run_initializers
      super
      init_on(:draw) do
        @count = 0
        @check_fps = CheckFPS.new
        @screen_active = true

        screen_open
        screen_info_check

        if Stylet.config.hide_mouse
          SDL::Mouse.hide
        end

        if @title
          self.title = @title
        end

        backgroud_image_load

        # background_clear

        # SGE関係でウィンドウを自動ロックさせる(これは必要なのか？)
        if SDL.respond_to?(:auto_lock)
          SDL.auto_lock = true
        end
      end
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
      screen_destroy
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
        when SDL::Event::KeyDown
          if @sdl_event.sym == SDL::Key::ESCAPE || @sdl_event.sym == SDL::Key::Q
            throw :exit, :break
          end
          if @sdl_event.sym == SDL::Key::F1
            full_screen_toggle
          end
        when SDL::Event::Active
          if (@sdl_event.state & SDL::Event::APPINPUTFOCUS).nonzero?
            @screen_active = @sdl_event.gain
          end
        when SDL::Event::VideoResize
          Stylet.config.screen_size = [@sdl_event.w, @sdl_event.h]
          screen_open
        when SDL::Event::Quit
          throw :exit, :break
        end
      end
    end

    def key_down?(sym)
      if @sdl_event.kind_of? SDL::Event::KeyDown
        @sdl_event.sym == sym
      end
    end

    def __draw_line(x0, y0, x1, y1, color)
      @screen.draw_line(x0, y0, x1, y1, Palette.fetch(color))
    end

    #
    # draw_rect の場合、デフォルトだと幅+1ドット描画されるため -1 してある
    #
    def _draw_rect(x, y, w, h, options = {})
      options = {
        :color => :foreground,
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
      @screen.send(method, x, y, w, h, Palette.fetch(options[:color]))
    end

    def draw_line(p0, p1, options = {})
      options = {
        :color => :foreground,
      }.merge(options)
      @screen.draw_line(p0.x, p0.y, p1.x, p1.y, Palette.fetch(options[:color]))
    rescue RangeError => error
      # warn [p0, p1].inspect
      # raise error
    end

    def draw_dot(p0, options = {})
      draw_line(p0, p0, options)
    end

    def draw_rect(rect, options = {})
      _draw_rect(rect.x, rect.y, rect.w, rect.h, options)
    end

    def save_bmp(fname)
      @screen.save_bmp(fname)
    end

    def system_line
      if Stylet.production
        "#{@count} #{@check_fps.fps}"
      else
        "#{@count} #{@check_fps.fps} FPS SE:#{SDL::Mixer.playing_channels}/#{SE.allocated_channels} #{@rect.w}x#{@rect.h} #{app_state}"
      end
    end

    def before_update
      super
      # return if Stylet.production
      @check_fps.update
      vputs(system_line)
    end

    def full_screen_toggle
      Stylet.config.full_screen = !Stylet.config.full_screen
      screen_open
    end

    private

    def screen_open
      screen_destroy            # 既存サーフェスを破棄しないとGCの際に落ちる
      @screen = SDL::Screen.open(*Stylet.config.screen_size, Stylet.config.color_depth, screen_flags)
      @rect = Rect2.new(@screen.w, @screen.h)
    end

    def screen_destroy
      if @screen
        unless @screen.destroyed?
          @screen.destroy
        end
        @screen = nil
      end
    end

    def screen_flags
      options = Stylet.config.screen_flags
      options |= SDL::FULLSCREEN if Stylet.config.full_screen
      options
    end

    def screen_info_check
      # フルスクリーンで利用可能なサイズ
      Stylet.logger.debug "SDL::Screen.list_modes # => #{SDL::Screen.list_modes(SDL::FULLSCREEN|SDL::HWSURFACE).inspect}"

      # 画面情報
      Stylet.logger.debug "SDL::Screen.info # => #{SDL::Screen.info.inspect}"
    end

    def app_state
      app_state_list = {SDL::Event::APPMOUSEFOCUS => "M", SDL::Event::APPINPUTFOCUS => "K", SDL::Event::APPACTIVE => "A"}
      app_state_list.collect{|k, v|
        if (SDL::Event.app_state & k).nonzero?
          v
        end
      }.join
    end

    def backgroud_image_load
      unless @backgroud_image
        if Stylet.config.background_image
          file = Pathname(Stylet.config.background_image)
          unless file.exist?
            file = Pathname("#{__dir__}/assets/#{file}")
          end
          if file.exist?
            bin = SDL::Surface.load(file.to_s)              # SDL.image があればBMP以外をロード可
            bin.set_color_key(SDL::SRCCOLORKEY, 0) if false # 黒を抜き色にするなら
            @backgroud_image = bin.display_format
          end
        end
      end
    end

    # オーバーライド推奨
    def background_clear
      if @backgroud_image
        SDL::Surface.blit(@backgroud_image, @rect.x, @rect.y, @rect.w, @rect.h, @screen, 0, 0)
      else
        draw_rect(@rect, :color => :background, :fill => true)
      end
    end
  end
end

if $0 == __FILE__
  require_relative "../stylet"
  Stylet.run
end

# SDL描画関連

module Stylet
  module Draw
    attr_reader :frame_counter, :sdl_event, :srect, :screen, :screen_active, :renderer
    attr_reader :fps_stat, :cpu_stat
    attr_reader :title

    def run_initializers
      super
      init_on(:draw) do
        @frame_counter = 0
        @fps_adjust = FpsAdjust.new
        @fps_stat = FpsStat.new
        @cpu_stat = CpuStat.new
        @screen_active = true

        screen_open
        screen_info_check

        if Stylet.config.hide_mouse
          SDL2::Mouse.hide
        end

        if @title
          self.title = @title
        end
      end
    end

    # ハードウェアがダブルバッファ対応の場合flipで自動的にVSYNCを待って切り替えるため
    # ハードウェアのフレーム数(60FPS)以上にはならない
    def screen_flip
      super
      @fps_adjust.delay
      @fps_stat.update
      @cpu_stat.benchmark { @renderer.present }
      @frame_counter += 1
    end

    def after_run
      super
      screen_destroy
      backgroud_image_destroy
    end

    def title=(str)
      if str
        if @title != str
          @title = str
          if @screen
            SDL2::WM.set_caption(@title.to_s, @title.to_s)
          end
        end
      end
    end

    def event_receive
      super

      case @sdl_event
      when SDL2::Event::KeyDown
        if @sdl_event.sym == SDL2::Key::Scan::ESCAPE || @sdl_event.sym == SDL2::Key::Scan::Q
          throw :exit, :break
        end
        if @sdl_event.sym == SDL2::Key::Scan::K1
          full_screen_toggle
        end
      when SDL2::Event::Window::SHOWN
        if (@sdl_event.state & SDL2::Event::APPINPUTFOCUS).nonzero?
          @screen_active = @sdl_event.gain
        end
      when SDL2::Event::Window::RESIZED
        screen_resize(@sdl_event.w, @sdl_event.h)
      when SDL2::Event::Quit
        throw :exit, :break
      end
    end

    def key_down?(sym)
      if @sdl_event.is_a? SDL2::Event::KeyDown
        @sdl_event.sym == sym
      end
    end

    def __draw_line(x0, y0, x1, y1, color)
      @screen.draw_line(x0, y0, x1, y1, Palette.fetch(color))
    end

    # draw_rect の場合、デフォルトだと幅+1ドット描画されるため -1 してある
    # draw_rect(0, 0, 0, 0) で 1 ドット表示されてしまう
    #
    def draw_rect4(x, y, w, h, color: :foreground, fill: false, alpha: nil, surface: @renderer)
      return if w.zero? || h.zero?
      color = Palette.fetch(color)
      # raise "w, h は正を指定するように" if w < 0 || h < 0
      if fill
        if alpha
          surface.draw_rect(x, y, w.abs - 1, h.abs - 1, color, true, alpha)
        else

          # surface.fill_rect(x, y, w.abs, h.abs, color)
          #
          # surface.draw_blend_mode = background_blend_mode
          surface.draw_color = color
          surface.fill_rect(SDL2::Rect.new(x, y, w.abs, h.abs))
        end
      else
        surface.draw_rect(x, y, w.abs - 1, h.abs - 1, color, false, alpha)
      end
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

    def draw_dot(p0, **options)
      draw_line(p0, p0, **options)
    end

    def draw_rect(rect, **options)
      draw_rect4(*rect, **options)
    end

    def save_bmp(fname)
      @screen.save_bmp(fname)
    end

    def system_infos
      list = [
        @frame_counter,
        "FPS:#{@fps_stat.fps}",
        "CPU:#{format("%4.2f", @cpu_stat.cpu_ratio)}",
      ]
      if Stylet.production
      else
        list += [
          # "SE:#{SDL2::Mixer.playing_channels}/#{SE.allocated_channels}",
          # "M#{SDL2::Mixer.play_music? ? 1 : 0}",
          "#{@srect.w}x#{@srect.h}",
          app_state,
        ]
      end
      list
    end

    def before_update
      super
      # return if Stylet.production
      if v = system_infos.presence
        vputs v.compact.join(" ")
      end
    end

    def full_screen_toggle
      Stylet.config.full_screen = !Stylet.config.full_screen
      screen_open
    end

    def screen_resize(w, h)
      Stylet.config.screen_size = [w, h]
      screen_open
    end

    private

    def screen_open
      screen_destroy    # 既存サーフェスを破棄しないとGCの際に落ちる
      # @screen = SDL2::Screen.open(*Stylet.config.screen_size, Stylet.config.color_depth, screen_flags)
      # @srect = Rect2.new(@screen.w, @screen.h)

      pos = SDL2::Window::POS_CENTERED
      @screen = SDL2::Window.create("(Title)", pos, pos, *Stylet.config.screen_size, screen_flags)
      @srect = Rect2.new(*@screen.size)

      @renderer = @screen.create_renderer(-1, Stylet.config.renderer_flags)
    end

    def screen_destroy
      if @screen
        unless @screen.destroy?
          @screen.destroy
        end
        @screen = nil
      end
    end

    def screen_flags
      flags = Stylet.config.screen_flags
      if Stylet.config.full_screen
        flags |= SDL2::Window::Flags::FULLSCREEN
        # flags |= SDL2::Window::Flags::FULLSCREEN_DESKTOP
      end
      flags
    end

    def screen_info_check
      # logger.debug "SGE: #{SDL2.respond_to?(:auto_lock).inspect}"

      # フルスクリーンで利用可能なサイズ
      SDL2::Display.displays.each do |display|
        logger.debug display.name
        logger.debug display.current_mode
        logger.debug display.desktop_mode
      end

      # logger.debug "SDL2::Screen.list_modes # => #{SDL2::Screen.list_modes(SDL2::FULLSCREEN | SDL2::HWSURFACE).inspect}"

      # 画面情報
      # logger.debug "SDL2::Screen.info # => #{SDL2::Screen.info.inspect}"
    end

    def app_state
      app_state_list = {
        # SDL2::Event::APPMOUSEFOCUS => "M",
        # SDL2::Event::APPINPUTFOCUS => "K",
        # SDL2::Event::APPACTIVE     => "A",
        
        # SDL2::Event::Window::ENTER        => "M",
        # SDL2::Event::Window::FOCUS_GAINED => "K",
        # SDL2::Event::Window::SHOWN        => "A",


      }
      app_state_list.collect { |k, v|
        if (SDL2::Event.app_state & k).nonzero?
          v
        end
      }.join
    end

    # オーバーライド推奨
    def background_clear
      simple_background_clear
    end

    def simple_background_clear
      draw_rect(@srect, :color => :background, :fill => true)
    end
  end

  concern :DeprecateBackground do
    def screen_open
      super

      @backgroud_image ||= background_image_load
    end

    def background_clear
      if @backgroud_image
        SDL2::Surface.blit(@backgroud_image, @srect.x, @srect.y, @srect.w, @srect.h, @screen, 0, 0)
      else
        super
      end
    end

    def background_image_load
      if v = Stylet.config.background_image
        file = Pathname(v)
        if file.exist?
          bin = SDL2::Surface.load(file.to_s)
          bin.display_format
        end
      end
    end

    def backgroud_image_destroy
      if @backgroud_image
        @backgroud_image.destroy
        @backgroud_image = nil
      end
    end
  end
end

if $0 == __FILE__
  require_relative "../stylet"
  Stylet.run
end

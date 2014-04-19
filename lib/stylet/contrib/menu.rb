# -*- coding: utf-8 -*-
require "stylet"

module Stylet
  class Menu
    include Stylet::Delegators
    include Stylet::Input::Base
    include Stylet::Input::ExtensionButton

    include Stylet::Input::StandardKeybordBind
    include Stylet::Input::JoystickBindMethod

    attr_reader :children
    attr_reader :state
    attr_reader :parent
    attr_reader :select_button, :cancel_button

    def initialize(parent: nil, name: nil, list: [], select_button: :btA, cancel_button: :btD)
      super() if defined? super

      @list          = list
      @parent        = parent
      @name         = name
      @select_button = select_button
      @cancel_button = cancel_button

      @cursor         = 0
      @window_cursor  = @cursor
      @display_height = 16

      @state = State.new(:menu_start)
      @children = []

      # Stylet::SE.load_file("#{__dir__}/../../../sound_effects/arcade_sf2_se/20H.wav", :key => :startup)
      Stylet::SE.load_file("#{__dir__}/../../../sound_effects/psp_kingdom_hearts_birth_by_sleep_ui_sounds/bbs_menu.wav", :key => :startup)
      Stylet::SE.load_file("#{__dir__}/../../../sound_effects/psp_kingdom_hearts_birth_by_sleep_ui_sounds/bbs_scroll.wav", :key => :scroll)
      Stylet::SE.load_file("#{__dir__}/../../../sound_effects/psp_kingdom_hearts_birth_by_sleep_ui_sounds/bbs_back.wav", :key => :back)
    end

    def add(params)
      Stylet::SE[:startup].play
      @children << self.class.new({:name => current[:name], :parent => self}.merge(params))
      @state.jump_to(:menu_sleep)
    end

    def update
      super if defined? super

      unless @parent
        update_by_joy(joys.first)
        key_counter_update_all
      end

      @state.loop_in do
        case @state.state
        when :menu_start
          unless @parent
            # Stylet::SE[:startup].play
          end
          @state.jump_to(:menu_alive)
        when :menu_sleep
          @children.each(&:update)
        when :menu_restart
          if @state.start?
            Stylet::SE[:back].play
          end
          @state.jump_to(:menu_alive)
        when :menu_alive
          if @state.count >= 1  # サブメニューを開いた瞬間に最初の項目を押させないため
            update_cursor
            close_check
            current_run
          end
          update_window_cursor
          render
        end
      end
    end

    def root
      if @parent
        @parent.root
      else
        self
      end
    end

    private

    def render
      if @name
        rendar_bar
        vputs @name
      end
      rendar_bar
      @display_height.times do |i|
        _index = @window_cursor + i
        unless @list[_index]
          break
        end
        menu_str = @list[_index][:name]
        if _index == @cursor
          vputs "-> #{menu_str}"
        else
          vputs "   #{menu_str}"
        end
      end
      rendar_bar
    end

    def current_run
      if root.button.send(root.select_button).trigger? || root.axis.right.trigger? || Stylet::Base.active_frame.key_down?(SDL::Key::RETURN)
        if current[:menu]
          add(current[:menu])
        end
        if command = current[:command]
          Stylet::SE[:scroll].play
          case command
          when Symbol
            send(command)
          else
            command.call(self)
            # if command.arity == 1
            #   command.call(self)
            # else
            #   instance_exec(&command)
            # end
          end
          Stylet::Music.fade_out
        end
      end
    end

    def update_cursor
      if v = Stylet::Input::Support.preference_key(root.axis.up, root.axis.down)
        if v.repeat >= 1
          d = 0
          if v == root.axis.up
            if @cursor > 0
              d = -1
            end
          else
            if @cursor < @list.size - 1
              d = 1
            end
          end
          if d.nonzero?
            @cursor += d
            Stylet::SE[:scroll].play
          end
        end
      end
    end

    def rendar_bar
      vputs "----------------------------------------"
    end

    def close_check
      if root.button.send(root.cancel_button).trigger? || root.axis.left.trigger? || Stylet::Base.active_frame.key_down?(SDL::Key::BACKSPACE)
        close
      end
    end

    def update_window_cursor
      if @cursor - @window_cursor < scroll_line
        if @window_cursor > 0
          @window_cursor -= 1
        end
      end
      if @cursor - @window_cursor >= @display_height - scroll_line
        if @window_cursor < @list.size - @display_height
          @window_cursor += 1
        end
      end
    end

    def current
      @list[@cursor]
    end

    def scroll_line
      @scroll_line || (@display_height / 3)
    end

    def close
      if parent
        parent.children.delete(self)
        parent.state.jump_to(:menu_restart)
      else
        # throw :exit, :break
      end
    end
  end
end

if $0 == __FILE__
  class Window < SimpleDelegator
    def initialize
      super(Stylet::Base.active_frame)
      @c = 0
    end

    def update_loop
      main_loop do |x|
        if @c >= 60
          break
        end
        vputs "#{self.class.name}: #{@c}"
        @c += 1
      end
    end
  end

  #--------------------------------------------------------------------------------
  # 方法1
  #--------------------------------------------------------------------------------

  if true
    class App1 < SimpleDelegator
      def initialize
        super(Stylet::Base.active_frame)

        @menu = Stylet::Menu.new(name: "[メニュー]", list: [
            {name: "実行", command: proc { Window.new.update_loop }},
            {name: "サブメニュー", command: proc {|s|
                s.add(name: "[サブメニュー]", list: [
                    {name: "実行", command: proc { Window.new.update_loop }},
                    {name: "A", command: proc { p 1 }},
                    {name: "B", command: proc { p 2 }},
                    {name: "閉じる", command: :close },
                  ])
              }},
            {name: "サブメニュー2", command: proc {|s| s.add(name: "[サブメニュー2]", list: 16.times.collect{|i|{:name => "項目#{i}"}})}},
            {name: "サブメニュー3", menu: {name: "[サブメニュー3]", list: 16.times.collect{|i|{:name => "項目#{i}"}}}},
            {:name => "閉じる", command: :close },
          ])

      end

      def update_loop
        main_loop{|s| @menu.update }
      end
    end

    App1.new.update_loop
  end

  #--------------------------------------------------------------------------------
  # 方法2
  #--------------------------------------------------------------------------------

  if false
    # この方法でもいいけど update コールバックが Singleton のインスタンスに結び付いてしまうのため
    # Window クラスでも update が実行されてしまう
    class App2 < Stylet::Base
      setup do
        @menu = Stylet::Menu.new(list: [{name: "RUN", command: -> { Window.new.update_loop }}])
      end
      update do
        @menu.update
      end
      run
    end
  end
end

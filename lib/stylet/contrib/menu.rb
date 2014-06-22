# -*- coding: utf-8 -*-
require "stylet"
require "active_support/core_ext/hash/keys" # for assert_valid_keys

module Stylet
  module Menu
    module Core
      extend ActiveSupport::Concern

      include Stylet::Delegators
      include Stylet::Input::Base
      include Stylet::Input::ExtensionButton

      include Stylet::Input::StandardKeybordBind
      include Stylet::Input::JoystickBindMethod

      attr_accessor :parent, :bar, :display_height, :select_buttons, :cancel_buttons, :line_format, :close_hook
      attr_reader :state, :children

      def initialize(parent: nil, name: nil, elements: [], select_buttons: [:btA, :btD], cancel_buttons: [:btB, :btC], scroll_margin: nil, bar: "─" * 40, display_height: 20, joystick_index: nil, line_format: " %{cursor}%{name} %{value}", close_hook: nil)
        super() if defined? super

        @parent         = parent
        @name           = name
        @elements       = elements
        @select_buttons = select_buttons
        @cancel_buttons = cancel_buttons
        @scroll_margin  = scroll_margin
        @bar            = bar
        @display_height = display_height
        @joystick_index = joystick_index
        @line_format    = line_format
        @close_hook     = close_hook

        @cursor         = 0
        @window_cursor  = @cursor

        @state = State.new(:menu_boot)
        @children = []
      end

      def chain(params)
        notify(:menu_chain)

        params = params.dup
        menu_class = params.delete(:menu_class) || self.class
        @children << menu_class.new({:name => current[:name], :parent => self}.merge(params))
        @state.jump_to(:menu_sleep)
      end

      def update
        super if defined? super
        unless @parent
          active_joys.each{|e|update_by_joy(e)}
          key_counter_update_all
        end
        @state.loop_in do
          case @state.state
          when :menu_boot
            bgm_if_possible
            @state.jump_to(:menu_alive)
          when :menu_sleep
            @children.each(&:update)
          when :menu_restart
            if @state.start?
              bgm_if_possible
              notify(:menu_back)
            end
            @state.jump_to(:menu_alive)
          when :menu_alive
            if @state.count >= 1  # サブメニューを開いた瞬間に最初の項目を押させないため
              update_cursor
              close_check
              current_run
            end
            current_value_change
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
        unless @bar
          vputs
        end
        if menu_name
          rendar_bar
          vputs menu_name
        end
        rendar_bar
        @elements.slice(@window_cursor, @display_height).each {|element| element_display(element) }
        rendar_bar
      end

      def menu_name
        if @name.respond_to?(:call)
          @name.call
        else
          @name
        end
      end

      def element_display(element)
        vputs line_format % {
          :cursor => element_cursor(element),
          :name   => element_name(element),
          :value  => element_value(element),
        }
      end

      def element_cursor(element)
        if element == current
          "〉"
        else
          "  "
        end
      end

      def element_name(element)
        if element[:name].respond_to?(:call)
          element[:name].call
        else
          element[:name]
        end
      end

      def element_value(element)
        if element[:value]
          element[:value].call
        end
      end

      def current_run
        # if root.button.send(root.select_buttons).trigger? || root.axis.right.trigger? || Stylet::Base.active_frame.key_down?(SDL::Key::RETURN)
        if root.select_buttons.any?{|e|root.button.send(e).trigger?} || Stylet::Base.active_frame.key_down?(SDL::Key::RETURN)
          current.assert_valid_keys(:name, :menu, :soft_command, :pon_command, :safe_command, :change, :value)
          if menu = current[:menu]
            if menu.respond_to?(:call)
              menu = menu.call
            end
            chain(menu)
          end
          if command = current[:soft_command]
            command.call(self)
          end
          if command = current[:pon_command]
            notify(:menu_select)
            command.call(self)
          end
          if command = current[:sym_command]
            send(command)
          end
          if safe_command = current[:safe_command]
            Stylet::Audio.halt
            safe_command.call(self)
            Stylet::Audio.halt
            bgm_if_possible
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
              if @cursor < @elements.size - 1
                d = 1
              end
            end
            if d != 0
              @cursor += d
              notify(:menu_cursor)
            end
          end
        end
      end

      def rendar_bar
        if @bar
          vputs @bar
        end
      end

      def close_check
        # if root.button.send(root.cancel_buttons).trigger? || root.axis.left.trigger? || Stylet::Base.active_frame.key_down?(SDL::Key::BACKSPACE)
        if root.cancel_buttons.any?{|e|root.button.send(e).trigger?} || Stylet::Base.active_frame.key_down?(SDL::Key::BACKSPACE)
          close
        end
      end

      def update_window_cursor
        if @cursor - @window_cursor < scroll_margin
          if @window_cursor > 0
            @window_cursor -= 1
          end
        end
        if @cursor - @window_cursor >= @display_height - scroll_margin
          if @window_cursor < @elements.size - @display_height
            @window_cursor += 1
          end
        end
      end

      def current
        @elements.fetch(@cursor)
      end

      def scroll_margin
        @scroll_margin || (@display_height / 3)
      end

      # close methods
      begin
        def close_and_parent_restart
          if parent
            if @close_hook
              @close_hook.call(self)
            end
            parent.children.delete(self)
            parent.state.jump_to(:menu_restart)
          end
        end

        alias close close_and_parent_restart

        def force_close
          throw :exit, :break
        end
      end

      def notify(key)
      end

      def bgm_if_possible
      end

      def current_value_change
        if current[:change]
          if plus_or_minus_integer.nonzero?
            current[:change].call(plus_or_minus_integer)
          end
        end
      end

      def plus_or_minus_integer
        case e = Input::Support.preference_key(root.axis.right, root.axis.left)
        when root.axis.right
          e.repeat
        when root.axis.left
          e.repeat * -1
        else
          0
        end
      end

      def active_joys
        if @joystick_index
          joys[@joystick_index, 1] || []
        else
          joys
        end
      end
    end

    module Soundable
      extend ActiveSupport::Concern

      def initialize(*)
        super if defined? super

        # Stylet::SE.load("#{__dir__}/../../../sound_effects/garage_band/menu_boot.aif",   volume: 0.2)
        # Stylet::SE.load("#{__dir__}/../../../sound_effects/garage_band/menu_chain.aif",  volume: 0.2)
        # Stylet::SE.load("#{__dir__}/../../../sound_effects/garage_band/menu_select.aif", volume: 0.2)
        # Stylet::SE.load("#{__dir__}/../../../sound_effects/garage_band/menu_cursor.aif", volume: 0.2)
        # Stylet::SE.load("#{__dir__}/../../../sound_effects/garage_band/menu_back.aif",   volume: 0.2)

        Stylet::SE.load("#{__dir__}/../../../sound_effects/pc_puyo_puyo_fever/SE/039CURSOR.WAV", volume: 0.5, key: :menu_cursor)
        Stylet::SE.load("#{__dir__}/../../../sound_effects/pc_puyo_puyo_fever/SE/036DECIDE.WAV", volume: 0.5, key: :menu_select)
        Stylet::SE.load("#{__dir__}/../../../sound_effects/pc_puyo_puyo_fever/SE/037CANCEL.WAV", volume: 0.5, key: :menu_back)
        Stylet::SE.load("#{__dir__}/../../../sound_effects/pc_puyo_puyo_fever/SE/036DECIDE.WAV", volume: 0.5, key: :menu_chain)

        # Stylet::SE.load("#{__dir__}/../../../sound_effects/garage_band/menu_chain.aif",  volume: 0.2)
        # Stylet::SE.load("#{__dir__}/../../../sound_effects/garage_band/menu_select.aif", volume: 0.2)
        # Stylet::SE.load("#{__dir__}/../../../sound_effects/garage_band/menu_cursor.aif", volume: 0.2)
        # Stylet::SE.load("#{__dir__}/../../../sound_effects/garage_band/menu_back.aif",   volume: 0.2, key: menu_back)
      end

      def notify(key)
        Stylet::SE[key].play
      end

      def bgm_if_possible
        unless Stylet::Music.play?
          # Stylet::Music.play("#{__dir__}/../../../sound_effects/garage_band/menu_boot.aif")
          Stylet::Music.play("#{__dir__}/../../../sound_effects/pc_puyo_puyo_fever/BGM/01_MENU.ogg")
        end
      end
    end

    class Simple
      include Core
    end

    class Basic
      include Core
      include Soundable
    end
  end

  if $0 == __FILE__
    class SampleWindow < SimpleDelegator
      def initialize
        super(Stylet::Base.active_frame)
        @c = 0
      end

      def counter_loop
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
    # 例1
    #--------------------------------------------------------------------------------

    if true
      class App1 < SimpleDelegator
        def initialize
          super(Stylet::Base.active_frame)

          @test_var = 0
          @menu = Stylet::Menu::Basic.new(elements: [
              {name: "モード", safe_command: proc {}, :value => -> { @test_var }, :change => proc {|v| @test_var += v }},

              {name: "実行", safe_command: proc { SampleWindow.new.counter_loop }},
              {name: "サブメニュー", soft_command: proc {|s|
                  s.chain(name: "sub menu", elements: [
                      {name: "実行", safe_command: proc { SampleWindow.new.counter_loop }},
                      {name: "A", safe_command: proc { p 1 }},
                      {name: "B", safe_command: proc { p 2 }},
                      {name: "閉じる", soft_command: :close },
                    ])
                }},
              {name: "サブメニュー2", soft_command: proc {|s| s.chain(name: "[サブメニュー2]", elements: 16.times.collect{|i|{:name => "項目#{i}"}})}},
              {name: "サブメニュー3", menu: {name: "[サブメニュー3]", elements: 16.times.collect{|i|{:name => "項目#{i}"}}}},
              {:name => "閉じる", soft_command: :close },
            ])

        end

        def counter_loop
          main_loop{|s| @menu.update }
        end
      end

      App1.new.counter_loop
    end

    #--------------------------------------------------------------------------------
    # 例2
    #--------------------------------------------------------------------------------

    if false
      # この例でもいいけど update コールバックが Singleton のインスタンスに結び付いてしまうのため
      # SampleWindow クラスでも update が実行されてしまう
      class App2 < Stylet::Base
        setup do
          @menu = Stylet::Menu::Basic.new(elements: [{name: "RUN", safe_command: proc { SampleWindow.new.counter_loop }}])
        end
        update do
          @menu.update
        end
        run
      end
    end
  end
end

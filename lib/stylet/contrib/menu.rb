# -*- coding: utf-8 -*-
require "stylet"
require_relative "shared_pad"

module Stylet
  module Menu
    module Core
      extend ActiveSupport::Concern

      include Stylet::Delegators

      attr_accessor :parent, :bar, :display_height, :select_buttons, :cancel_buttons, :line_format, :close_hook, :input, :elements
      attr_reader :state, :children

      def initialize(parent: nil, name: nil, elements: [], select_buttons: [:btA, :btD], cancel_buttons: [:btB, :btC], scroll_margin: nil, bar: "─" * 40, display_height: 20, joystick_index: nil, line_format: " %{cursor}%{name} %{value}", close_hook: nil, input: Input::SharedPad.new, aroundable: true, cursor: 0)
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
        @input          = input
        @aroundable     = aroundable

        @cursor         = cursor
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

          @input.key_bit_update_all
          @input.key_counter_update_all

          # active_joys.each{|e|bit_update_by_joy(e)}
          # key_counter_update_all
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
            cursor_update
            if @state.count > 1 # サブメニューを開いた瞬間や戻ってきたときに最初の項目を押させないため
              close_check
              all_run
              current_run
            end
            current_value_change
            window_cursor_update
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

      def force_close
        throw :exit, :break
      end

      def close_trigger?
        root.cancel_buttons.any?{|e|root.input.button.send(e).trigger?} || Stylet::Base.active_frame.key_down?(SDL::Key::BACKSPACE)
      end

      begin
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

        def all_run
          @elements.each do |elem|
            if command = elem[:every_command]
              command.call(self)
            end
          end
        end

        def current_run
          current.assert_valid_keys(:name, :menu, :soft_command, :pon_command, :safe_command, :change, :value, :every_command, :cursor_in, :cursor_out)

          # if root.input.button.send(root.select_buttons).trigger? || root.input.axis.right.trigger? || Stylet::Base.active_frame.key_down?(SDL::Key::RETURN)
          if root.select_buttons.any?{|e|root.input.button.send(e).trigger?} || Stylet::Base.active_frame.key_down?(SDL::Key::RETURN)
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
            # if command = current[:sym_command]
            #   send(command)
            # end
            if safe_command = current[:safe_command]
              Stylet::Audio.halt
              notify(:menu_select)
              safe_command.call(self)
              Stylet::Audio.halt
              bgm_if_possible

              # ブロックの中でBキャンセルしたときにこのメニューもBキャンセルが反応してしまうのを防ぐため
              # メニューをリスタートさせる。リスタートすることで2フレーム間、Bキャンセルをかわせる
              @state.jump_to(:menu_restart)
            end
          end
        end

        def cursor_update
          if v = Stylet::Input::Support.preference_key(root.input.axis.up, root.input.axis.down)
            if v.repeat >= 1
              d = 0
              if v == root.input.axis.up
                if @aroundable || @cursor > 0
                  d = -1
                end
              else
                if @aroundable || @cursor < @elements.size - 1
                  d = 1
                end
              end
              if d != 0
                c = (@cursor + d).modulo(@elements.size)
                if c != @cursor
                  before = current
                  @cursor = c
                  notify(:menu_cursor)

                  if m = before[:cursor_out]
                    if m.respond_to?(:call)
                      m.call(self)
                    end
                  end
                  if m = current[:cursor_in]
                    if m.respond_to?(:call)
                      m.call(self)
                    end
                  end
                end
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
          if close_trigger?
            close_and_parent_restart
          end
        end

        def window_cursor_update
          d = scroll_margin - (@cursor - @window_cursor)
          if d >= 1
            @window_cursor -= d
          end
          d = (@cursor - @window_cursor) - (@display_height - scroll_margin - 1)
          if d >= 1
            @window_cursor += d
          end
          @window_cursor = Stylet::Etc.clamp(@window_cursor, window_range)
        end

        def window_range
          max = @elements.size - @display_height
          if max < 0
            max = 0
          end
          0..max
        end

        def current
          @elements.fetch(@cursor)
        end

        def scroll_margin
          @scroll_margin || (@display_height / 3)
        end

        # close methods
        def close_and_parent_restart
          if parent
            if @close_hook
              @close_hook.call(self)
            end
            parent.children.delete(self)
            parent.state.jump_to(:menu_restart)
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
          case e = Input::Support.preference_key(root.input.axis.right, root.input.axis.left)
          when root.input.axis.right
            e.repeat
          when root.input.axis.left
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
    end

    module Soundable
      extend ActiveSupport::Concern

      def initialize(*)
        super if defined? super

        Stylet::SE.load("#{__dir__}/../../../sound_effects/pc_puyo_puyo_fever/SE/039CURSOR.WAV", volume: 0.5, key: :menu_cursor)
        Stylet::SE.load("#{__dir__}/../../../sound_effects/pc_puyo_puyo_fever/SE/036DECIDE.WAV", volume: 0.5, key: :menu_select)
        Stylet::SE.load("#{__dir__}/../../../sound_effects/pc_puyo_puyo_fever/SE/037CANCEL.WAV", volume: 0.5, key: :menu_back)
        Stylet::SE.load("#{__dir__}/../../../sound_effects/pc_puyo_puyo_fever/SE/036DECIDE.WAV", volume: 0.5, key: :menu_chain)
      end

      def notify(key)
        Stylet::SE[key].play
      end

      def bgm_if_possible
        unless Stylet::Music.play?
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
                      {name: "閉じる", soft_command: :close_and_parent_restart },
                    ])
                }},
              {name: "サブメニュー2", soft_command: proc {|s| s.chain(name: "[サブメニュー2]", elements: 50.times.collect{|i|{:name => "項目#{i}"}})}},
              {name: "サブメニュー3", menu: {name: "[サブメニュー3]", elements: 50.times.collect{|i|{:name => "項目#{i}"}}}},
              {:name => "閉じる", soft_command: :close_and_parent_restart },
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

# -*- coding: utf-8 -*-
require "stylet"
require_relative "shared_pad"

module Stylet
  module Menu
    module Core
      extend ActiveSupport::Concern

      include Stylet::Delegators

      attr_accessor :parent, :bar, :display_height, :select_buttons, :cancel_buttons, :line_format, :close_hook, :input, :elements, :every_command_all
      attr_reader :state, :children

      def initialize(**params)
        super() if defined? super

        {
          :parent            => nil,
          :name              => nil,
          :elements          => [],
          :select_buttons    => [:btA, :btD],
          :cancel_buttons    => [:btB, :btC],
          :scroll_margin     => nil,
          :bar               => "─" * 40,
          :display_height    => 20,
          :joystick_index    => nil,
          :line_format       => " %{cursor}%{name} %{value}",
          :close_hook        => nil,
          :input             => Input::SharedPad.new,
          :aroundable        => false,
          :cursor            => 0,
          :every_command_all => nil,
        }.merge(params).each{|k, v|instance_variable_set("@#{k}", v)}

        @window_cursor  = @cursor
        @state = State.new(:boot)
        @children = []
      end

      def chain(params)
        notify(:menu_chain)

        params = params.dup
        menu_class = params.delete(:menu_class) || self.class
        @children << menu_class.new({:name => current[:name], :parent => self}.merge(params))
        @state.jump_to :ms_sleep
      end

      def update
        super if defined? super
        unless @parent
          @input.key_bit_update_all
          @input.key_counter_update_all
        end
        @state.loop_in { send @state.state }
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

      def diff_val
        case e = Input::Support.preference_key(root.input.axis.right, root.input.axis.left)
        when root.input.axis.right
          e.repeat
        when root.input.axis.left
          e.repeat * -1
        else
          0
        end
      end

      begin
        private

        def boot
          bgm_if_possible
          @state.jump_to :ms_alive
        end

        def ms_sleep
          @children.each(&:update)
        end

        def ms_restart
          if @state.start?
            bgm_if_possible
            notify(:menu_back)
          end
          @state.jump_to :ms_alive
        end

        def ms_alive
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

        def render
          # unless @bar
          #   vputs
          # end
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
          if @every_command_all
            @every_command_all.call(self)
          end
          @elements.each do |elem|
            if command = elem[:danger_every_command_all]
              command.call(self)
            end
          end
        end

        def current_run
          return unless current
          current.assert_valid_keys(:name, :menu, :simple_command, :se_command, :safe_command, :change, :change2, :value, :danger_every_command_all, :every_command_one, :cursor_in, :cursor_out)

          if command = current[:every_command_one]
            command.call(self)
          end

          if current_run_trigger?
            if menu = current[:menu]
              if menu.respond_to?(:call)
                menu = menu.call
              end
              chain(menu)
            end
            if command = current[:simple_command]
              command.call(self)
            end
            if command = current[:se_command]
              notify(:menu_select)
              command.call(self)
            end
            if command = current[:safe_command]
              safe_command_around { command.call(self) }
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
          unless @elements.empty?
            @elements.fetch(@cursor)
          end
        end

        def scroll_margin
          @scroll_margin || (@display_height / 3)
        end

        def close_and_parent_restart
          if parent
            if @close_hook
              @close_hook.call(self)
            end
            parent.children.delete(self)
            parent.state.jump_to :ms_restart
          end
        end

        def notify(key)
        end

        def bgm_if_possible
        end

        def current_value_change
          if current
            if diff_val.nonzero?
              if current[:change]
                current[:change].call(diff_val)
              end
              if current[:change2]
                current[:change2].call(self)
              end
            end
          end
        end

        def active_joys
          if @joystick_index
            joys[@joystick_index, 1] || []
          else
            joys
          end
        end

        def current_run_trigger?
          root.select_buttons.any?{|e|root.input.button.send(e).trigger?} || Stylet::Base.active_frame.key_down?(SDL::Key::RETURN)
        end

        def safe_command_around
          Stylet::Audio.halt
          notify(:menu_select)
          yield
          Stylet::Audio.halt
          bgm_if_possible

          # yield内でBキャンセルしたときにこのメニューもBキャンセルが反応してしまう。
          # この対策としてメニューをリスタートさせる。
          # リスタートすることで2フレーム間Bキャンセルを回避できる。
          @state.jump_to :ms_restart
        end
      end
    end

    module Soundable
      extend ActiveSupport::Concern

      def initialize(*)
        super if defined? super

        Stylet::SE.load("#{__dir__}/../../../assets/audios/pc_puyo_puyo_fever/SE/039CURSOR.WAV", volume: 0.5, key: :menu_cursor)
        Stylet::SE.load("#{__dir__}/../../../assets/audios/pc_puyo_puyo_fever/SE/036DECIDE.WAV", volume: 0.5, key: :menu_select)
        Stylet::SE.load("#{__dir__}/../../../assets/audios/pc_puyo_puyo_fever/SE/037CANCEL.WAV", volume: 0.5, key: :menu_back)
        Stylet::SE.load("#{__dir__}/../../../assets/audios/pc_puyo_puyo_fever/SE/036DECIDE.WAV", volume: 0.5, key: :menu_chain)
      end

      def notify(key)
        Stylet::SE[key].play
      end

      def bgm_if_possible
        unless Stylet::Music.play?
          Stylet::Music.play("#{__dir__}/../../../assets/audios/pc_puyo_puyo_fever/BGM/01_MENU.ogg")
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
        main_loop do |_|
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

          if false
            @menu = Stylet::Menu::Basic.new
          else
            @test_var = 0
            @menu = Stylet::Menu::Basic.new(elements: [
                {name: "モード", safe_command: proc {}, :value => proc { @test_var }, :change => proc {|v| @test_var += v }},

                {name: "実行", safe_command: proc { SampleWindow.new.counter_loop }},
                {
                  name: "サブメニュー",
                  simple_command: proc {|s|
                    s.chain(name: "sub menu", elements: [
                        {name: "実行", safe_command: proc { SampleWindow.new.counter_loop }},
                        {name: "A", safe_command: proc { p 1 }},
                        {name: "B", safe_command: proc { p 2 }},
                        {name: "閉じる", simple_command: :close_and_parent_restart },
                      ])
                  },
                },
                {name: "サブメニュー2", simple_command: proc {|s| s.chain(name: "[サブメニュー2]", elements: 50.times.collect{|i|{:name => "項目#{i}"}})}},
                {name: "サブメニュー3", menu: {name: "[サブメニュー3]", elements: 50.times.collect{|i|{:name => "項目#{i}"}}}},
                {:name => "閉じる", simple_command: :close_and_parent_restart },
              ])
          end
        end

        def counter_loop
          main_loop{|_| @menu.update }
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

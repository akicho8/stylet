# -*- coding: utf-8 -*-
require "stylet"

module Stylet
  module Menu
    module Core
      extend ActiveSupport::Concern

      include Stylet::Delegators
      include Stylet::Input::Base
      include Stylet::Input::ExtensionButton

      include Stylet::Input::StandardKeybordBind
      include Stylet::Input::JoystickBindMethod

      attr_reader :children
      attr_reader :state
      attr_reader :parent
      attr_reader :select_button, :cancel_button

      def initialize(parent: nil, name: nil, list: [], select_button: [:btA, :btD], cancel_button: [:btB, :btC])
        super() if defined? super

        @list          = list
        @parent        = parent
        @name         = name
        @select_button = select_button
        @cancel_button = cancel_button

        @cursor         = 0
        @window_cursor  = @cursor
        @display_height = 20

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
          joys.each{|e|update_by_joy(e)}
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
            vputs " 〉#{menu_str}"
          else
            vputs "   #{menu_str}"
          end
        end
        rendar_bar
      end

      def current_run
        # if root.button.send(root.select_button).trigger? || root.axis.right.trigger? || Stylet::Base.active_frame.key_down?(SDL::Key::RETURN)
        if root.select_button.any?{|e|root.button.send(e).trigger?} || Stylet::Base.active_frame.key_down?(SDL::Key::RETURN)
          current.assert_valid_keys(:name, :menu, :soft_command, :safe_command)
          if menu = current[:menu]
            if menu.respond_to?(:call)
              menu = menu.call
            end
            chain(menu)
          end
          if soft_command = current[:soft_command]
            case soft_command
            when Symbol
              send(soft_command)
            else
              soft_command.call(self)
            end
          end
          if safe_command = current[:safe_command]
            case safe_command
            when Symbol
              send(safe_command)
            else
              Stylet::Audio.halt
              safe_command.call(self)
              Stylet::Audio.halt
              bgm_if_possible
            end
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
              notify(:menu_scroll)
            end
          end
        end
      end

      def rendar_bar
        vputs "────────────────────────────────────"
      end

      def close_check
        # if root.button.send(root.cancel_button).trigger? || root.axis.left.trigger? || Stylet::Base.active_frame.key_down?(SDL::Key::BACKSPACE)
        if root.cancel_button.any?{|e|root.button.send(e).trigger?} || Stylet::Base.active_frame.key_down?(SDL::Key::BACKSPACE)
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
        @list.fetch(@cursor)
      end

      def scroll_line
        @scroll_line || (@display_height / 3)
      end

      # close methods
      begin
        def close_and_parent_restart
          if parent
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
    end

    module MenuSound
      extend ActiveSupport::Concern

      def initialize(*)
        super if defined? super
        Stylet::SE.load("#{__dir__}/../../../sound_effects/garage_band/menu_boot.aif",   volume: 0.2)
        Stylet::SE.load("#{__dir__}/../../../sound_effects/garage_band/menu_chain.aif",  volume: 0.2)
        Stylet::SE.load("#{__dir__}/../../../sound_effects/garage_band/menu_select.aif", volume: 0.2)
        Stylet::SE.load("#{__dir__}/../../../sound_effects/garage_band/menu_scroll.aif", volume: 0.2)
        Stylet::SE.load("#{__dir__}/../../../sound_effects/garage_band/menu_back.aif",   volume: 0.2)
      end

      def notify(key)
        Stylet::SE[key].play
      end

      def bgm_if_possible
        unless Stylet::Music.play?
          Stylet::Music.play("#{__dir__}/../../../sound_effects/garage_band/menu_boot.aif")
        end
      end
    end

    class Simple
      include Core
    end

    class Soundy
      include Core
      include MenuSound
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

          @menu = Stylet::Menu::Soundy.new(list: [
              {name: "実行", safe_command: proc { SampleWindow.new.counter_loop }},
              {name: "サブメニュー", soft_command: proc {|s|
                  s.chain(name: "sub menu", list: [
                      {name: "実行", safe_command: proc { SampleWindow.new.counter_loop }},
                      {name: "A", safe_command: proc { p 1 }},
                      {name: "B", safe_command: proc { p 2 }},
                      {name: "閉じる", soft_command: :close },
                    ])
                }},
              {name: "サブメニュー2", soft_command: proc {|s| s.chain(name: "[サブメニュー2]", list: 16.times.collect{|i|{:name => "項目#{i}"}})}},
              {name: "サブメニュー3", menu: {name: "[サブメニュー3]", list: 16.times.collect{|i|{:name => "項目#{i}"}}}},
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
          @menu = Stylet::Menu::Soundy.new(list: [{name: "RUN", safe_command: proc { SampleWindow.new.counter_loop }}])
        end
        update do
          @menu.update
        end
        run
      end
    end
  end
end

# -*- coding: utf-8 -*-
require_relative "helper"

menu = Stylet::Menu.new(name: "[メニュー]", list: [
    {name: "実行", command: -> s { Stylet.run { vputs "Hello World" }; s.state.jump_to(:menu_restart) }},
    {name: "サブメニュー", command: -> s {
        s.add(name: "[サブメニュー]", list: [
            {name: "A", command: -> { p 1 }},
            {name: "B", command: -> s { p 2 }},
            {name: "閉じる", command: :close },
          ])
      }},
    {name: "サブメニュー2", command: -> s { s.add(name: "[サブメニュー2]", list: 16.times.collect{|i|{:name => "項目#{i}"}})}},
    {:name => "閉じる", :command => :close },
  ])

Stylet.run {|s| menu.update }

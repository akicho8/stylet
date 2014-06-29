# -*- coding: utf-8 -*-
require_relative "helper"

menu = Stylet::Menu::Basic.new(name: "[メニュー]", elements: [
    {name: "実行", safe_command: proc { Stylet.run { vputs "Hello World" } }},
    {name: "サブメニュー", safe_command: proc {|s|
        s.chain(name: "[サブメニュー]", elements: [
            {name: "A", safe_command: proc { p 1 }},
            {name: "B", safe_command: proc { p 2 }},
            {name: "閉じる", safe_command: :close_and_parent_restart },
          ])
      }},
    {name: "サブメニュー2", safe_command: proc { s.chain(name: "[サブメニュー2]", elements: 16.times.collect{|i|{:name => "項目#{i}"}})}},
    {:name => "閉じる", :safe_command => :close_and_parent_restart },
  ])

Stylet.run {|s| menu.update }

# -*- coding: utf-8 -*-

require 'stylet_math/all'

# gem
require 'sdl'
require 'active_support/concern'
require 'active_support/callbacks'

# ruby library
require 'pp'
require 'singleton'
require 'pathname'

require 'stylet/config'

# 汎用ライブラリ
require_relative 'palette'
require_relative 'fps_adjust'
require_relative 'check_fps'
require_relative 'logger'
require_relative 'rect'
require_relative 'collision_support'

# 描画系
require_relative 'core'
require_relative 'callbacks'
require_relative 'system_pause'
require_relative 'cl_options'
require_relative 'draw'
require_relative 'font'
require_relative 'shortcut'

# 描画サポート
require_relative 'draw_support/circle'
require_relative 'draw_support/polygon'
require_relative 'draw_support/arrow'
require_relative 'draw_support/bar'

# 入力系
require_relative 'joystick'
require_relative 'keyboard'
require_relative 'mouse'

# オーディオ系
require_relative 'audio'

# その他
require_relative 'delegators'

module Stylet
  class Base
    include Core
    include Callbacks
    include Draw
    include DrawSupport
    include Font
    include Joystick
    include Keyboard
    include Mouse
    include Pause
    include ClOptions
    include Shortcut
    include Delegators
  end
end

if $0 == __FILE__
  Stylet::Base.run
end

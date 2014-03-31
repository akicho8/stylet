# -*- coding: utf-8 -*-
# コマンドライン対応
#  ruby sample.rb --shutdown=60 とすれば60フレーム後に終了する
#  サンプルプログラムを連続実行して落ちないことを確認するために作成

require "optparse"

module Stylet
  module ClOptions
    module Base
      extend ActiveSupport::Concern

      attr_reader :cl_options

      def initialize
        super if defined? super
        @cl_options = {}
        oparser = OptionParser.new do |oparser|
          oparser.on("--fps=INTEGER", Integer){|v|Stylet.config.fps = v}
          oparser.on("--shutdown=INTEGER", Integer){|v|@cl_options[:shutdown] = v}
          oparser.on("-f", "--full-screen", TrueClass){|v|Stylet.config.full_screen = true}
          oparser.on("-p", "--production", TrueClass){|v|Stylet.production = true}
          oparser.on("-s", "--screen-size=SIZE", String){|v|Stylet.config.screen_size = [*v.scan(/\d+/).collect(&:to_i)]}
          oparser.on("-c", "--color-depth=DEPTH", Integer){|v|Stylet.config.color_depth = v}
        end
        if Stylet.config.optparse_enable
          oparser.parse(ARGV)
        end
      end
    end

    module Shutdown
      def update
        super if defined? super
        if @cl_options[:shutdown] && @count >= @cl_options[:shutdown]
          throw :exit, :break
        end
      end
    end

    module All
      extend ActiveSupport::Concern
      include Base
      include Shutdown
    end
  end
end

if $0 == __FILE__
  require_relative "../stylet"
  ARGV << "--shutdown=3600"
  ARGV << "--screen-size=800x600"
  ARGV << "--full-screen"
  ARGV << "--production"
  Stylet.run do
    vputs cl_options
    vputs Stylet.config
  end
end

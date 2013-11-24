# -*- coding: utf-8 -*-
# コマンドライン対応
#  ruby sample.rb --shutdown=60 とすれば60フレーム後に終了する
#  サンプルプログラムを連続実行して落ちないことを確認するために作成

require "optparse"

module Stylet
  module ClOptions
    attr_reader :cl_options

    def initialize
      super if defined? super
      @cl_options = {}
      oparser = OptionParser.new do |oparser|
        oparser.on("--shutdown=INTEGER", Integer){|v|@cl_options[:shutdown] = v}
        oparser.on("-f", "--full-screen", TrueClass){|v|Stylet.config.full_screen = true}
        oparser.on("-p", "--production", TrueClass){|v|Stylet.config.production = true}
        oparser.on("-s", "--screen-size=SIZE", String){|v|Stylet.config.screen_size = [*v.scan(/\d+/).collect(&:to_i)]}
      end
      oparser.parse(ARGV)
      p Stylet.config.screen_size
    end

    def update
      super if defined? super
      if @cl_options[:shutdown] && @count >= @cl_options[:shutdown]
        throw :exit, :break
      end
    end
  end
end

if $0 == __FILE__
  require_relative "../stylet"
  ARGV << "--shutdown=60"
  ARGV << "--screen-size=800x600"
  ARGV << "--full-screen"
  ARGV << "--production"
  Stylet.run
end

#
# コマンドライン対応
#
#  サンプルプログラムを連続実行して動作確認
#  rsdl foo.rb bar.rb --shutdown=60

require "optparse"

module Stylet
  module ClOptions
    def self.oparser
      @oparser ||= OptionParser.new do |oparser|
        oparser.on("--fps=INTEGER", Integer)             {|v| Stylet.config.fps = v                                        }
        oparser.on("--shutdown=INTEGER", Integer)        {|v| Stylet.config.shutdown = v                                   }
        oparser.on("-f", "--full-screen", TrueClass)     {|v| Stylet.config.full_screen = v                                }
        oparser.on("-p", "--production", TrueClass)      {|v| Stylet.production = v                                        }
        oparser.on("-s", "--screen-size=SIZE", String)   {|v| Stylet.config.screen_size = [*v.scan(/\d+/).collect(&:to_i)] }
        oparser.on("-c", "--color-depth=DEPTH", Integer) {|v| Stylet.config.color_depth = v                                }
        oparser.on("-m", "--mute-mute", TrueClass)       {|v| Stylet.config.mute_music = v                                 }
        oparser.on("-M", "--mute", TrueClass)            {|v| Stylet.config.mute = v                                       }
        oparser.on("-i", "--hide-mouse", TrueClass)      {|v| Stylet.config.hide_mouse = v                                 }
      end
    end

    concerning :Base do
      def initialize
        super if defined? super
        return if Stylet.config.optparse_skip || ENV["STYLET_OPTPARSE_SKIP"]
        ClOptions.oparser.order!(ARGV)
      end
    end

    concerning :Shutdown do
      def update
        super if defined? super
        if Stylet.config.shutdown && frame_counter >= Stylet.config.shutdown
          throw :exit, :break
        end
      end
    end
  end
end

if $0 == __FILE__
  $LOAD_PATH << ".."
  require "stylet"
  ARGV << "--shutdown=3600"
  ARGV << "--screen-size=800x600"
  ARGV << "--full-screen"
  ARGV << "--production"
  Stylet.run do
    vputs Stylet.config
  end
end

# -*- coding: utf-8 -*-

require "./setup"

Stylet::FontList.send(:static_record_list_set, Stylet.config.font_list + [
    {:key => :font_small,  :path => "LiberationMono-Bold.ttf", :bold => true, :font_size => 12},
    {:key => :font_midium, :path => "LiberationMono-Bold.ttf", :bold => true, :font_size => 16},
    {:key => :font_large,  :path => "LiberationMono-Bold.ttf", :bold => true, :font_size => 24},
    {:key => :coda,        :path => "Coda-Regular.ttf",        :bold => false, :font_size => 14},
  ])

Stylet.run do
  Stylet::FontList.each {|e| vputs [e.key, "Aa12KIA_漢;:"].join(" "), :font => e }

  vputs "bold true", :bold => true
  vputs "bold false", :bold => false
end

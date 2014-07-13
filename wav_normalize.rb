# -*- coding: utf-8 -*-
# 22050 or 44100 に統一
require "pathname"
require "shellwords"
path = "sound_effects/replacement/**/*.{WAV,wav}"

def normalize(in_file, hz)
  out_file = in_file.dirname + "tmp_#{in_file.basename('.*')}.WAV"
  system "sox #{in_file.to_s.shellescape} -r #{hz} #{out_file.to_s.shellescape}"
  system "rm -f #{in_file.to_s.shellescape}"
  system "mv #{out_file.to_s.shellescape} #{in_file.to_s.shellescape}"
end

Pathname.glob(Pathname(path).expand_path){|in_file|
  info = `file #{in_file.to_s.shellescape}`
  if info.match(/Microsoft PCM/)
    case
    when info.match(/11025|22050|44100/)
    when info.match(/24000|32000|37800|48000/)
      normalize(in_file, 44100)
    when info.match(/16000/)
      normalize(in_file, 22050)
    when info.match(/\b(8000)\b/)
      normalize(in_file, 11025)
    else
      p info
    end
  else
    p info
  end
}

source "https://rubygems.org"
gemspec

path = File.expand_path(File.join(__dir__, "stylet_support"))
if File.exist?(path)
  gem "stylet_support", path: path
else
  gem "stylet_support", github: "akicho8/stylet_support"
end

# gem "ruby-opengl", require: false
gem "ruby-sdl2", require: "sdl2"
gem "matrix"

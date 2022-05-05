source 'https://rubygems.org'
gemspec

if File.exist? (path = File.expand_path(File.join(__dir__, "stylet_support")))
  gem "stylet_support", path: path
else
  gem "stylet_support", github: "akicho8/stylet_support"
end

gem "ruby-opengl", require: false

# bundle config build.rubysdl --enable-bundled-sge
# ~/.bundle/config
gem "rubysdl", github: "ohai/rubysdl"

gem "matrix"

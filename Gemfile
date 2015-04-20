source 'https://rubygems.org'
gemspec

if File.exist? (path = File.expand_path(File.join(File.dirname(__FILE__), "../static_record")))
  gem "static_record", :path => path
else
  gem "static_record", :github => "akicho8/static_record"
end

if File.exist? (path = File.expand_path(File.join(File.dirname(__FILE__), "stylet_math")))
  gem "stylet_math", :path => path
else
  gem "stylet_math", :github => "akicho8/stylet_math"
end

gem "ruby-opengl", :require => false
# gem "rubocop", :github => "bbatsov/rubocop", :require => false
gem "rubocop", :require => false

# bundle config build.rubysdl --enable-bundled-sge
# ~/.bundle/config
gem "rubysdl", :github => "ohai/rubysdl"

gem "stackprof"

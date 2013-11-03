source 'https://rubygems.org'
ruby '2.0.0'
gemspec

if File.exist? (path = File.expand_path(File.join(File.dirname(__FILE__), "stylet_math")))
  gem "stylet_math", :path => path
else
  gem "stylet_math", :github => "akicho8/stylet_math"
end

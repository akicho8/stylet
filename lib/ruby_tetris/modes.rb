Dir[File.expand_path(File.join(File.dirname(__FILE__), "modes/*.rb"))].each{|filename|require(filename)}

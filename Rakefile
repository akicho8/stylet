require "bundler"
Bundler::GemHelper.install_tasks

task :default => :test

require "rake/testtask"
Rake::TestTask.new do |t|
  t.libs << "test"
  # t.test_files = FileList['test/test*.rb']
  # t.verbose = true
  # t.options = "--no-use-color"
end

desc "examples/* の最低限の動作確認"
task :test_examples do
  system("cd examples && ruby test_all.rb")
end

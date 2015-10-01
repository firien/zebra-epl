require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new do |task|
  task.libs.push "lib"
  task.test_files = FileList['test/**/*_test.rb']
  task.verbose = true
end

desc 'Run tests'
task :default => :test
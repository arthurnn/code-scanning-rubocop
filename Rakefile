require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

task :qhelp do
  require_relative 'lib/code_scanning/qhelp_generator'

  begin
    puts "Cloning rubocop repository to read manuals"
    puts

    sh "git clone git@github.com:rubocop-hq/rubocop.git _tmp"

    gen = QHelpGenerator.new
    Dir["_tmp/manual/cops_*.md"].each do |f|
      gen.parse_file(f)
    end
    puts
    puts "Writing qhelp sarif to 'qhelps.sarif' file"
    puts
    File.write('qhelps.sarif', gen.sarif_json)
  ensure
    sh "rm -rf _tmp"
  end
end

task :default => :test

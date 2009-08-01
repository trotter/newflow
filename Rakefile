require 'rake'
require 'spec/rake/spectask'

SPEC_FILES = FileList['spec/*_spec.rb']

desc "Run all specs"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = SPEC_FILES
end

desc "Run rcov"
Spec::Rake::SpecTask.new('rcov') do |t|
  t.spec_files = SPEC_FILES
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec']
end


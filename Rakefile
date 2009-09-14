require 'rubygems'
require 'rake'
require 'rake/gempackagetask'
require 'spec/rake/spectask'

PKG_VERSION = '1.0.0'
SPEC_FILES  = FileList['spec/*_spec.rb']
PKG_FILES   = FileList['lib/**/*.rb',
                       'spec/**/*.rb']

task :default => :spec

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

spec = Gem::Specification.new do |s|
  s.name = 'newflow'
  s.version = PKG_VERSION
  s.summary = "Add workflows (state transitions) to objects."
  s.description = <<EOS
Newflow provides a way to add workflows to existing objects. It uses
a simple dsl to add guards and triggers to states and their transitions.
EOS
  
  s.files = PKG_FILES.to_a

  s.has_rdoc = false
  s.authors  = ["Trotter Cashion", "Kyle Burton", "Aaron Feng"]
  s.email    = "cashion@gmail.com"
  s.homepage = "http://trottercashion.com"
end

Rake::GemPackageTask.new(spec) do |t|
  t.need_tar = true
end


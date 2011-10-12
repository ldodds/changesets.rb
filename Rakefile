require 'rake'

require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'
require 'rake/clean'

NAME = "changesets"
VER = "0.1"

RDOC_OPTS = ['--quiet', '--title', 'RDF Changesets API']

PKG_FILES = %w( README.md Rakefile ) + 
  Dir.glob("{tests,lib}/**/*")

CLEAN.include ['*.gem', 'pkg']  
SPEC =
  Gem::Specification.new do |s|
    s.name = NAME
    s.version = VER
    s.platform = Gem::Platform::RUBY
    s.required_ruby_version = ">= 1.8.7"    
    s.has_rdoc = true
    s.rdoc_options = RDOC_OPTS
    s.summary = "RDF Changesets API"
    s.description = s.summary
    s.author = "Leigh Dodds"
    s.email = 'ld@kasabi.com'
    s.homepage = 'http://github.com/ldodds/changesets.rb'
    s.files = PKG_FILES
    s.require_path = "lib" 
    s.test_file = "tests/ts_changeset.rb"
    s.add_dependency("rdf")
    s.add_dependency("mocha", ">= 0.9.5")
  end
      
Rake::GemPackageTask.new(SPEC) do |pkg|
    pkg.need_tar = true
end

Rake::RDocTask.new do |rdoc|
    rdoc.rdoc_dir = 'doc/rdoc'
    rdoc.options += RDOC_OPTS
    rdoc.rdoc_files.include("CHANGES", "lib/**/*.rb")    
end

Rake::TestTask.new do |test|
  test.test_files = FileList['tests/tc_*.rb']
end

desc "Install from a locally built copy of the gem"
task :install do
  sh %{rake package}
  sh %{sudo gem install pkg/#{NAME}-#{VER}}
end

desc "Uninstall the gem"
task :uninstall => [:clean] do
  sh %{sudo gem uninstall #{NAME}}
end

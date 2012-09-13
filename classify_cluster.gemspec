# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "classify_cluster/version"

Gem::Specification.new do |s|
  s.name        = "classify_cluster"
  s.version     = ClassifyCluster::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Sean Cashin"]
  s.email       = ["sean@socialcast.com"]
  s.homepage    = "http://rubygems.org/gems/classify_cluster"
  s.summary     = %q{Contains several binaries for generating capistrano and puppet configurations}
  s.description = %q{Reading from a YAML file will allow for consistent configuration between capistrano and puppet}
  s.add_dependency(%q<thor>, ["~> 0.14"])
  s.add_dependency(%q<i18n>, [">= 0"])
  s.add_dependency(%q<activesupport>, [">= 3.0.0"])

  s.rubyforge_project = "classify_cluster"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end

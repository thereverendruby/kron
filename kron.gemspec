# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "kron/version"

Gem::Specification.new do |s|
  s.name        = "kron"
  s.version     = Kron::VERSION
  s.authors     = ["thereverendruby"]
  s.email       = ["thereverendruby@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{A Cron Utility For Rails.}
  s.description = %q{Kron is a utillty for running recurring background processes within Rails, with out the need for OS access.}

  s.rubyforge_project = "kron"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end

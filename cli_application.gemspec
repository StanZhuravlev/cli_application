# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cli_application/version'

Gem::Specification.new do |spec|
  spec.name          = "cli_application"
  spec.version       = CliApplication::VERSION
  spec.authors       = ["Stan Zhuravlev"]
  spec.email         = ["stan@post-api.ru"]
  spec.license       = "MIT"

  spec.summary       = %q{Библиотека для построения CLI-приложений}
  spec.description   = %q{Цель библиотеки - обеспечить быструю разработку CLI-приложений (скриптов).
    Повышение производительности разработки достигается за счет единообразной обработки файлов конфигуарции,
    удобной обработки аргументов командной строки, устаналиваемых централизованно соединений с базой данных,
    а также переиспользования моделей ActiveRecords Rails-приложений.}
  spec.homepage      = "https://github.com/StanZhuravlev/cli_application"
  spec.required_ruby_version = '~> 2.2.0'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  # http://yehudakatz.com/2010/04/02/using-gemspecs-as-intended/
  # spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.files         = Dir.glob("{bin,lib,test}/**/*") + %w(LICENSE.txt README.md)
  spec.files.reject! { |fn| fn.include? "config.yml" }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib", "lib/cli_application"]

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "st_tools", "~> 0.3", ">= 0.3"
  spec.add_development_dependency "activesupport", "~> 4.2.1", '>= 4.2.1'
end

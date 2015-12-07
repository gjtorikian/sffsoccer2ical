lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sffsoccer2ical/version'

Gem::Specification.new do |s|
  s.name          = 'sffsoccer2ical'
  s.version       = SFFSoccer2ICal::VERSION
  s.license       = 'MIT'

  s.summary       = 'A simple, blog aware, static site generator.'
  s.description   = 'Jekyll is a simple, blog aware, static site generator.'

  s.authors       = ['Garen J. Torikian']
  s.email         = 'gjtorikian@gmail.com'
  s.homepage      = 'https://github.com/gjtorikian/sffsoccer2ical'

  all_files       = `git ls-files -z`.split("\x0")
  s.files         = all_files.grep(%r{^(bin|lib)/})
  s.executables   = all_files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency 'trollop',          '~> 2.1'
  s.add_dependency 'nokogiri',         '~> 1.5'
  s.add_dependency 'ri_cal',           '0.8.8'
  s.add_dependency 'activesupport',    '~> 4.1'
  s.add_dependency 'chronic',          '~> 0.10'

  s.add_development_dependency 'awesome_print'
end

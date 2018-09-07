
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "purl/version"

Gem::Specification.new do |spec|
  spec.name          = "purl"
  spec.version       = Purl::VERSION
  spec.authors       = ["the purl authors"]

  spec.summary       = 'Ruby library to parse and build "purl" aka. package URLs.'
  spec.description   = 'Ruby library to parse and build "purl" aka. package URLs. This is a microlibrary implementing the purl spec at https://github.com/package-url'
  spec.homepage      = "https://github.com/package-url/packageurl-ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end

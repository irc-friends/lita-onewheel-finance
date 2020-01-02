Gem::Specification.new do |spec|
  spec.name          = "lita-onewheel-finance"
  spec.version       = "0.3.0
  spec.authors       = ["Andrew Kreps"]
  spec.email         = ["andrew.kreps@gmail.com"]
  spec.description   = "Wee li'l stock quote bot"
  spec.summary       = "Designed to query stock indicies and return relevant data."
  spec.homepage      = "https://github.com/onewheelskyward/lita-onewheel-finance"
  spec.license       = "MIT"
  spec.metadata      = { "lita_plugin_type" => "handler" }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'lita', '~> 4.7'
  spec.add_runtime_dependency 'rest-client', '~> 2'
  #spec.add_runtime_dependency 'nokogiri', '~> 1'

  spec.add_development_dependency 'bundler', '~> 2'
  #spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake', '~> 13'
  spec.add_development_dependency 'rack-test', '~> 0.8'
  spec.add_development_dependency 'rspec', '~> 3'
  spec.add_development_dependency 'simplecov', '~> 0.16'
  spec.add_development_dependency 'coveralls', '~> 0.8'
end

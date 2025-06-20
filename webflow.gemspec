# frozen_string_literal: true

require_relative 'lib/webflow/version'

Gem::Specification.new do |spec|
  spec.required_ruby_version = '>= 3.0'
  spec.name          = 'webflow-rb'
  spec.version       = Webflow::VERSION
  spec.authors       = %w[phoet vfonic]
  spec.email         = ['phoetmail@googlemail.com']
  spec.homepage      = 'https://github.com/vfonic/webflow-rb'
  spec.summary       = 'Webflow API wrapper'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }

  spec.metadata['rubygems_mfa_required'] = 'true'
end

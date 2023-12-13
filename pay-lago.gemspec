require_relative "lib/pay/lago/version"

Gem::Specification.new do |spec|
  spec.name = "pay-lago"
  spec.version = Pay::Lago::VERSION
  spec.authors = ["Moxvallix"]
  spec.email = ["dev@moxvallix.com"]

  spec.summary = "Lago processor support for Pay gem."
  spec.homepage = "https://github.com/demingfactor/pay-lago"
  spec.license = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/demingfactor/pay-lago"
  spec.metadata["changelog_uri"] = "https://github.com/demingfactor/pay-lago/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = `git ls-files -z`.split("\u0000")

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "pay", "~> 6.8"
  spec.add_dependency "lago-ruby-client", "0.53.0-beta"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end

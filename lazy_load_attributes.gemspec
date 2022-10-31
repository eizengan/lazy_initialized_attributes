# frozen_string_literal: true

require_relative "lib/lazy_load_attributes/version"

Gem::Specification.new do |spec|
  raise "RubyGems 2.0 or newer is required to protect against public gem pushes." unless spec.respond_to?(:metadata)

  spec.name = "lazy_load_attributes"
  spec.version = LazyLoadAttributes::VERSION
  spec.authors = ["Nate Eizenga"]
  spec.email = ["eizengan@gmail.com"]

  spec.summary = "Lazy loading for class attributes."
  spec.description = <<~DESCRIPTION
    A simple DSL for adding cached, lazy-loaded attributes to your classes. Transparent handling of inheritence,
    redefinition, etc.
  DESCRIPTION
  spec.homepage = "https://github.com/eizengan/lazy_load_attributes"
  spec.license = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = %w[
    CHANGELOG.md
    CODE_OF_CONDUCT.md
    lazy_load_attributes.gemspec
    README.md
  ] + Dir["lib/**/*"]
  spec.bindir = "bin"
  spec.executables += spec.files.grep(%r{\A#{spec.bindir}/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = [">= 2.7", "< 4"]

  spec.add_development_dependency "pry-byebug", "~> 3.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.21"
  spec.add_development_dependency "rubocop-performance", "~> 1.0"
  spec.add_development_dependency "rubocop-rake", "~> 0.0"
  spec.add_development_dependency "rubocop-rspec", "~> 2.0"
end

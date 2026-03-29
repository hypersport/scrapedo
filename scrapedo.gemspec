# frozen_string_literal: true

require_relative "lib/scrapedo/version"

Gem::Specification.new do |spec|
  spec.name = "scrapedo"
  spec.version = Scrapedo::VERSION
  spec.authors = ["hypersport"]
  spec.email = ["boss.yuan@outlook.com"]

  spec.summary = "Ruby Gem For Scrape.do"
  spec.description = "An unofficial Ruby gem designed to provide a convenient interface for Ruby developers. It eliminates the need to handle complex HTTP requests and parsing logic, allowing you to easily access data from the Scrapedo API (currently supports only Google Search API) within your applications. It supports all parameters of the [Google Search API](https://scrape.do/documentation/google-search-api/search/)."
  spec.homepage = "https://github.com/hypersport/scrapedo"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/hypersport/scrapedo"
  spec.metadata["changelog_uri"] = "https://github.com/hypersport/scrapedo/blob/main/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "https://github.com/hypersport/scrapedo/issues"
  spec.metadata["documentation_uri"] = "https://rubydoc.info/github/hypersport/scrapedo"
  spec.metadata["yard.run"] = "yri"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of the gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end

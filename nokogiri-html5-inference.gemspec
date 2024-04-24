# frozen_string_literal: true

require_relative "lib/nokogiri/html5/inference/version"

Gem::Specification.new do |spec|
  spec.name = "nokogiri-html5-inference"
  spec.version = Nokogiri::HTML5::Inference::VERSION
  spec.authors = ["Mike Dalessio"]
  spec.email = ["mike.dalessio@gmail.com"]

  spec.summary = "Given HTML5 input, make a reasonable guess at how to parse it correctly."
  spec.description = <<~DESC
    Infer from the HTML5 input whether it's a fragment or a document, and if it's a fragment what
    the proper context node should be. This is useful for parsing trusted content like view
    snippets, particularly for morphing cases like StimulusReflex.
  DESC
  spec.homepage = "https://github.com/flavorjones/nokogiri-html5-inference"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata = {
    "homepage_uri" => spec.homepage,
    "source_code_uri" => spec.homepage,
    "bug_tracker_uri" => "#{spec.homepage}/issues",
    "changelog_uri" => "#{spec.homepage}/blob/main/CHANGELOG.md"
  }

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = [
    ".rdoc_options",
    "CHANGELOG.md",
    "CODE_OF_CONDUCT.md",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "lib/nokogiri/html5/inference.rb",
    "lib/nokogiri/html5/inference/version.rb"
  ]
  spec.require_paths = ["lib"]

  spec.add_dependency "nokogiri", "~> 1.14"
end

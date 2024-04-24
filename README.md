# Nokogiri::Html5::Inference

Given HTML5 input, make a resonable guess at how to parse it correctly.

Infer from the HTML5 input whether it's a fragment or a document, and if it's a fragment what the proper context node should be. This is useful for parsing trusted content like view snippets, particularly for morphing cases like StimulusReflex.


## Installation

TODO: Replace `nokgiri-html5-inference` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

    $ bundle add nokgiri-html5-inference

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install nokgiri-html5-inference


## Usage

TODO: Write usage instructions here


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/flavorjones/nokogiri-html5-inference. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/flavorjones/nokogiri-html5-inference/blob/main/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).


## Code of Conduct

Everyone interacting in the Nokogiri::Html5::Inference project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/flavorjones/nokogiri-html5-inference/blob/main/CODE_OF_CONDUCT.md).

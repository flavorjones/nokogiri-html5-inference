# Nokogiri::HTML5::Inference

Given HTML5 input, make a reasonable guess at how to parse it correctly.

`Nokogiri::HTML5::Inference` makes reasonable inferences that work for both HTML5 documents and HTML5 fragments, and for all the different HTML5 tags that a web developer might need in a view library.

This is useful for parsing trusted content like view snippets, particularly for morphing cases like StimulusReflex.

## The problem this library solves

The [HTML5 Spec](https://html.spec.whatwg.org/multipage/parsing.html) defines some very precise context-dependent parsing rules which can make it challenging to "just parse" a fragment of HTML without knowing the parent node -- also called the "context node" -- in which it will be inserted.

Most content in an HTML5 document can be parsed assuming the parser's mode will be in the ["in body" insertion mode](https://html.spec.whatwg.org/multipage/parsing.html#parsing-main-inbody), but there are some notable exceptions. Perhaps the most problematic to web developers are the table-related tags, which will not be parsed properly unless the parser is in the ["in table" insertion mode](https://html.spec.whatwg.org/multipage/parsing.html#parsing-main-intable).

For example:

``` ruby
Nokogiri::HTML5::DocumentFragment.parse("<td>foo</td>").to_html
# => "foo" # where did the tag go!?
```

In the default "in body" mode, the parser will log an error, "Start tag 'td' isn't allowed here", and drop the tag. This particular fragment must be parsed "in the context" of a table in order to parse properly.

Thankfully, libgumbo and Nokogiri allow us to set the context node:

``` ruby
Nokogiri::HTML5::DocumentFragment.new(
  Nokogiri::HTML5::Document.new,
  "<td>foo</td>",
  "table"  # <--- this is the context node
).to_html
# => "<tbody><tr><td>foo</td></tr></tbody>"
```

This result is _almost_ correct, but we're seeing another HTML5 parsing rule in action: there may be _intermediate parent tags_ that the HTML5 spec requires to be inserted by the parser. In this case, the `<td>` tag must be wrapped in `<tbody><tr>` tags.

We can fix this to only return the tags we provided by using the `<template>` tag as the context node, which the HTML5 spec provides exactly for this purpose:

``` ruby
Nokogiri::HTML5::DocumentFragment.new(
  Nokogiri::HTML5::Document.new,
  "<td>foo</td>",
  "template"  # <--- this is the context node
).to_html
# => "<td>foo</td>"
```

Huzzah! That works. And it's precisely what `Nokogiri::HTML5::Inference.parse` does:

``` ruby
Nokogiri::HTML5::Inference.parse("<td>foo</td>").to_html
# => "<td>foo</td>"
```


## Usage

Given an input String containing HTML5, infer the best way to parse it by calling `Nokogiri::HTML5::Inference.parse`.

If the input is a document, you'll get a `Nokogiri::HTML5::Document` back:

``` ruby
html = <<~HTML
  <!doctype html>
  <html lang="en">
    <head>
      <meta charset="utf-8">
    </head>
    <body>
      <h1>Hello, world!</h1>
    </body>
  </html>
HTML

Nokogiri::HTML5::Inference.parse(html)
# => #(Document:0x1f04 {
#      name = "document",
#      children = [
#        #(DTD:0x2030 { name = "html" }),
#        #(Element:0x2134 {
#          name = "html",
#          attribute_nodes = [ #(Attr:0x2260 { name = "lang", value = "en" })],
#    ...
#    #(Element:0x2a44 {
#              name = "body",
#              children = [
#                #(Text "\n    "),
#                #(Element:0x2bd4 { name = "h1", children = [ #(Text "Hello, world!")] }),
#                #(Text "\n  \n\n")]
#              })]
#          })]
#      })
```

If the input is a fragment, you'll get back a `Nokogiri::XML::NodeSet`:

``` ruby
Nokogiri::HTML5::Inference.parse("<tr><td>hello</td><td>world!</td></tr>")
# => [
#     #<Nokogiri::XML::Element:0x4074 name="tr"
#       children=[
#         #<Nokogiri::XML::Element:0x4038 name="td" children=[#<Nokogiri::XML::Text:0x4024 "hello">]>,
#         #<Nokogiri::XML::Element:0x4060 name="td" children=[#<Nokogiri::XML::Text:0x404c "world!">]>
#       ]>
#    ]
```

Both of these return types respond to the same query methods like `#css` and `#xpath`, tree-traversal methods like `#children`, and serialization methods like `#to_html`.


## Caveats

The implementation is currently pretty hacky and only looks at the first tag in the input to make decisions. Nonetheless, it is a step forward from what Nokogiri and libgumbo do out-of-the-box.

The implementation also is almost certainly incomplete, meaning there are HTML5 tags that aren't handled by this library as you might expect.

This implementation is probably OK for handling untrusted content, but it's still new and I haven't really thought very hard about it yet. If you want to use it on untrusted content, open an issue and talk with us about your use case so we can help keep you secure!

We would welcome bug reports and pull requests improving this library!


## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add nokgiri-html5-inference
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install nokgiri-html5-inference
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/flavorjones/nokogiri-html5-inference. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/flavorjones/nokogiri-html5-inference/blob/main/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).


## Code of Conduct

Everyone interacting in the `Nokogiri::HTML5::Inference` project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/flavorjones/nokogiri-html5-inference/blob/main/CODE_OF_CONDUCT.md).

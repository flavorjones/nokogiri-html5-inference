# frozen_string_literal: true

require_relative "inference/version"

require "nokogiri"

if defined?(Nokogiri::HTML5::Inference) && Nokogiri::HTML5::Inference.respond_to?(:parse)
  # keep option open of merging into Nokogiri some day
  warn "NOTE: nokogiri-html5-inference is already loaded. Check for pinned issues at https://github.com/flavorjones/nokogiri-html5-inference/issues for more information."
else
  module Nokogiri
    module HTML5
      # :markup: markdown
      #
      #  The [HTML5 Spec](https://html.spec.whatwg.org/multipage/parsing.html) defines some very
      #  precise context-dependent parsing rules which can make it challenging to "just parse" a
      #  fragment of HTML without knowing the parent node -- also called the "context node" -- in
      #  which it will be inserted.
      #
      #  Most content in an HTML5 document can be parsed assuming the parser's mode will be in the
      #  ["in body" insertion
      #  mode](https://html.spec.whatwg.org/multipage/parsing.html#parsing-main-inbody), but there
      #  are some notable exceptions. Perhaps the most problematic to web developers are the
      #  table-related tags, which will not be parsed properly unless the parser is in the ["in
      #  table" insertion
      #  mode](https://html.spec.whatwg.org/multipage/parsing.html#parsing-main-intable).
      #
      #  For example:
      #
      #  ``` ruby
      #  Nokogiri::HTML5::DocumentFragment.parse("<td>foo</td>").to_html
      #  # => "foo" # where did the tag go!?
      #  ```
      #
      #  In the default "in body" mode, the parser will log an error, "Start tag 'td' isn't allowed
      #  here", and drop the tag. This particular fragment must be parsed "in the context" of a
      #  table in order to parse properly.
      #
      #  Thankfully, libgumbo and Nokogiri allow us to set the context node:
      #
      #  ``` ruby
      #  Nokogiri::HTML5::DocumentFragment.new(
      #    Nokogiri::HTML5::Document.new,
      #    "<td>foo</td>",
      #    "table"  # <--- this is the context node
      #  ).to_html
      #  # => "<tbody><tr><td>foo</td></tr></tbody>"
      #  ```
      #
      #  This result is _almost_ correct, but we're seeing another HTML5 parsing rule in action:
      #  there may be _intermediate parent tags_ that the HTML5 spec requires to be inserted by the
      #  parser. In this case, the `<td>` tag must be wrapped in `<tbody><tr>` tags.
      #
      #  We can fix this to only return the tags we provided by using the `<template>` tag as the
      #  context node, which the HTML5 spec provides exactly for this purpose:
      #
      #  ``` ruby
      #  Nokogiri::HTML5::DocumentFragment.new(
      #    Nokogiri::HTML5::Document.new,
      #    "<td>foo</td>",
      #    "template"  # <--- this is the context node
      #  ).to_html
      #  # => "<td>foo</td>"
      #  ```
      #
      #  Huzzah! That works. And it's precisely what `Nokogiri::HTML5::Inference.parse` does:
      #
      #  ``` ruby
      #  Nokogiri::HTML5::Inference.parse("<td>foo</td>").to_html
      #  # => "<td>foo</td>"
      #  ```
      #
      module Inference
        # Tags that must be parsed in a specific HTML5 insertion mode, for which we must use a
        # context node.
        module ContextTags # :nodoc:
          HTML = %w[head body].freeze
        end

        # Regular expressions used to determine if we need to use a context node.
        module ContextRegexp # :nodoc:
          DOCUMENT = /\A\s*(<!doctype\s+html\b|<html\b)/i
          HTML = /\A\s*<(#{ContextTags::HTML.join("|")})\b/i
        end

        # Regular expressions used to determine if we will need to skip an intermediate parent or
        # otherwise narrow the fragment DOM that is returned.
        module PluckRegexp # :nodoc:
          BODY_OUTER = /\A\s*<(body)\b/i
        end

        class << self
          #
          #  call-seq:
          #    parse(input, pluck: true) => (Nokogiri::HTML5::Document | Nokogiri::XML::NodeSet)
          #
          #  Based on the start of the input HTML5 string, guess whether it's a full document or a
          #  fragment and, using the fragment context node if necessary, parse it properly and
          #  return the correct set of nodes.
          #
          #  The keyword parameter +pluck+ can be set to +false+ to disable the narrowing of a
          #  parsed fragment to omit any intermediate parent nodes. This "plucking" is necessary,
          #  for example, when the input fragment begins with "<td>", which the HTML5 spec requires
          #  to be wrapped in <tt><tbody><tr>...</tr></tbody></tt> tags. By default, this method
          #  will return only the children of <tt><tbody><tr></tt>, but setting this flag to +false+
          #  will return the +tbody+ tag and its children.
          #
          #  [Parameters]
          #  - +input+ (String) The input HTML5 string, which may represent a document or a fragment.
          #
          #  [Keyword Parameters]
          #  - +pluck+ (Boolean) Default: +true+. Set to +false+ if you want the method to always
          #    return what Nokogiri parsed, without attempting to remove any sibling or intermediate
          #    parent nodes. This shouldn't be necessary if the library is working properly, but may
          #    be useful to allow user to work around a bad guess.
          #
          #  [Returns]
          #  - A +Nokogiri::HTML5::Document+ if the input appears to represent a full document.
          #  - A +Nokogiri::XML::NodeSet+ if the input appears to be a fragment.
          #
          def parse(input, pluck: true)
            context = Nokogiri::HTML5::Inference.context(input)
            if context.nil?
              Nokogiri::HTML5::Document.parse(input)
            else
              fragment = Nokogiri::HTML5::DocumentFragment.new(Nokogiri::HTML5::Document.new, input, context)
              if pluck && (path = pluck_path(input))
                fragment.xpath(path)
              else
                fragment.children
              end
            end
          end

          #
          #  call-seq: context(input) => (String | nil)
          #
          #  Based on the start of the input HTML5 string, make a guess about whether it's a full
          #  document or a document fragment; and if it's a fragment, whether we need to parse it
          #  within a specific context node.
          #
          #  [Parameters]
          #  - +input+ (String) The input HTML5 string, which may represent a document or a fragment.
          #
          #  [Returns]
          #    The String name of the context node required to parse the fragment, or +nil+ if the
          #    input represents a full document.
          #
          def context(input) # :nodoc:
            case input
            when ContextRegexp::DOCUMENT then nil
            when ContextRegexp::HTML then "html"
            else "template"
            end
          end

          #
          #  call-seq: pluck_path(input) => (String | nil)
          #
          #  Based on the start of the input HTML5 fragment string, determine whether the fragment
          #  will need to be selected out of a parent node. This is necessary, for example, when the
          #  fragment begins with "<td>", a tag which the HTML5 spec requires to be wrapped in
          #  "<tbody><tr>...</tr></tbody>".
          #
          #  [Parameters]
          #  - +input+ (String) The input HTML5 string, which should represent a fragment (not a full document).
          #
          #  [Returns]
          #    The String XPath query of the context node required to parse the fragment, or +nil+
          #    if no plucking is necessary.
          #
          def pluck_path(input) # :nodoc:
            case input
            when PluckRegexp::BODY_OUTER then "body"
            end
          end
        end
      end
    end
  end
end

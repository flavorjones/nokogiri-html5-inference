# frozen_string_literal: true

require_relative "inference/version"
require "nokogiri"

if defined?(Nokogiri::HTML5::Inference)
  # keep option open of merging into Nokogiri some day
  warn "NOTE: nokogiri-html5-inference is already loaded. Check for pinned issues at https://github.com/flavorjones/nokogiri-html5-inference/issues for more information."
else
  module Nokogiri
    module HTML5
      module Inference
        module Tags
          TABLE = %w[thead tbody tfoot tr td th col colgroup caption].freeze
          HTML = %w[head body].freeze
        end

        module Regexp
          DOCUMENT = /\A\s*(<!doctype\s+html\b|<html\b)/i
          TABLE = /\A\s*<(#{Tags::TABLE.join("|")})\b/i
          HTML = /\A\s*<(#{Tags::HTML.join("|")})\b/i
        end

        class << self
          def context(input)
            peek = input[0, 100]

            case peek
            when Regexp::DOCUMENT then nil
            when Regexp::TABLE then "table"
            when Regexp::HTML then "html"
            else
              "body"
            end
          end

          def parse(input)
            context = Nokogiri::HTML5::Inference.context(input)
            if context.nil?
              Nokogiri::HTML5::Document.parse(input)
            else
              Nokogiri::HTML5::DocumentFragment.new(Nokogiri::HTML5::Document.new, input, context)
            end
          end
        end
      end
    end
  end
end

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
        module ContextTags
          TABLE = %w[thead tbody tfoot tr td th col colgroup caption].freeze
          HTML = %w[head body].freeze
        end

        module ContextRegexp
          DOCUMENT = /\A\s*(<!doctype\s+html\b|<html\b)/i
          TABLE = /\A\s*<(#{ContextTags::TABLE.join("|")})\b/i
          HTML = /\A\s*<(#{ContextTags::HTML.join("|")})\b/i
        end

        module PluckTags
          TBODY = %w[tr].freeze
          TBODY_TR = %w[td th].freeze
          COLGROUP = %w[col].freeze
        end

        module PluckRegexp
          TBODY = /\A\s*<(#{PluckTags::TBODY.join("|")})\b/i
          TBODY_TR = /\A\s*<(#{PluckTags::TBODY_TR.join("|")})\b/i
          COLGROUP = /\A\s*<(#{PluckTags::COLGROUP.join("|")})\b/i
          HEAD_OUTER = /\A\s*<(head)\b/i
          BODY_OUTER = /\A\s*<(body)\b/i
        end

        class << self
          def context(input)
            case input
            when ContextRegexp::DOCUMENT then nil
            when ContextRegexp::TABLE then "table"
            when ContextRegexp::HTML then "html"
            else "body"
            end
          end

          def pluck_path(input)
            case input
            when PluckRegexp::TBODY then "tbody/*"
            when PluckRegexp::TBODY_TR then "tbody/tr/*"
            when PluckRegexp::COLGROUP then "colgroup/*"
            when PluckRegexp::HEAD_OUTER then "head"
            when PluckRegexp::BODY_OUTER then "body"
            end
          end

          def parse(input, pluck: true)
            context = Nokogiri::HTML5::Inference.context(input)
            if context.nil?
              Nokogiri::HTML5::Document.parse(input)
            else
              fragment = Nokogiri::HTML5::DocumentFragment.new(Nokogiri::HTML5::Document.new, input, context)
              if pluck && (path = pluck_path(input))
                fragment.xpath(path)
              else
                fragment
              end
            end
          end
        end
      end
    end
  end
end

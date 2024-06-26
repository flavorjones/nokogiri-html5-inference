# frozen_string_literal: true

require "test_helper"

describe Nokogiri::HTML5::Inference do
  fragment_actions = {
    "template" => [
      "<div>hello</div>",
      "<div class=\"big\">hello</div>",
      "<li>hello</li>",
      "<dl><dd>hello</dd><dt>world</dt></dl>",
      "<dd>hello</dd><dt>world</dt>",
      "just some text",
      "<thead><tr><td>hello</td></tr></thead>",
      "<tbody><tr><td>hello</td></tr></tbody>",
      "<tfoot><tr><td>hello</td></tr></tfoot>",
      "<tr><th>hello</th></tr>",
      "<tr><td>hello</td></tr>",
      "<th>hello</th>",
      "<td>hello</td>",
      "<colgroup><col class=\"hello\"></colgroup>",
      "<col class=\"hello\">",
      "<caption>hello</caption>"
    ],
    "html" => [
      "<body><div>hello</div></body>",
      "<head><meta charset=\"UTF-8\"><title>hello</title></head><body><div>hello</div></body>"
    ]
  }

  describe ".context" do
    describe "passed a Document with doctype" do
      it "returns nil" do
        assert_nil(Nokogiri::HTML5::Inference.context("<!doctype html><html><head></head><body></body></html>"))
        assert_nil(Nokogiri::HTML5::Inference.context(" <!doctype   html><html><head></head><body></body></html>"))
        assert_nil(Nokogiri::HTML5::Inference.context("<!DOCTYPE HTML><HTML><HEAD></HEAD><BODY></BODY></HTML>"))
      end
    end

    describe "passed a Document without doctype" do
      it "returns nil" do
        assert_nil(Nokogiri::HTML5::Inference.context("<html><head></head><body></body></html>"))
        assert_nil(Nokogiri::HTML5::Inference.context(" <html lang='en'><head></head><body></body></html>"))
        assert_nil(Nokogiri::HTML5::Inference.context("<HTML><HEAD></HEAD><BODY></BODY></HTML>"))
      end
    end

    fragment_actions.each do |context, fragments|
      describe "passed a fragment requiring 'in #{context}' insertion mode" do
        it "returns '#{context}'" do
          fragments.each do |fragment|
            actual = Nokogiri::HTML5::Inference.context(fragment)

            assert_equal(context, actual, "   Given: #{fragment.inspect}")
          end
        end
      end
    end
  end

  describe ".parse" do
    describe "passed a Document with doctype" do
      it "returns a Document" do
        actual = Nokogiri::HTML5::Inference.parse("<!doctype html><html><head></head><body></body></html>")

        assert_kind_of(Nokogiri::HTML5::Document, actual)
        assert_equal("<!DOCTYPE html><html><head></head><body></body></html>", actual.to_html)

        actual = Nokogiri::HTML5::Inference.parse("<!DOCTYPE HTML><HTML><HEAD></HEAD><BODY></BODY></HTML>")

        assert_kind_of(Nokogiri::HTML5::Document, actual)
        assert_equal("<!DOCTYPE html><html><head></head><body></body></html>", actual.to_html)
      end
    end

    describe "passed a Document without doctype" do
      it "returns a Document" do
        actual = Nokogiri::HTML5::Inference.parse("<html><head></head><body></body></html>")

        assert_kind_of(Nokogiri::HTML5::Document, actual)
        assert_equal("<html><head></head><body></body></html>", actual.to_html)

        actual = Nokogiri::HTML5::Inference.parse("<HTML><HEAD></HEAD><BODY></BODY></HTML>")

        assert_kind_of(Nokogiri::HTML5::Document, actual)
        assert_equal("<html><head></head><body></body></html>", actual.to_html)
      end
    end

    fragment_actions.each do |context, fragments|
      describe "passed a fragment requiring 'in #{context}' insertion mode" do
        fragments.each do |fragment|
          it "parses '#{fragment}' correctly" do
            actual = Nokogiri::HTML5::Inference.parse(fragment)

            assert_kind_of(Nokogiri::XML::NodeSet, actual)
            assert_equal(fragment, actual.to_html)
          end
        end
      end
    end

    describe "passed a Fragment containing head and body" do
      it "returns a Fragment containing both head and body" do
        fragment = "<head></head><body></body>"
        actual = Nokogiri::HTML5::Inference.parse(fragment)

        assert_kind_of(Nokogiri::XML::NodeSet, actual)
        assert_equal(fragment, actual.to_html)
      end
    end

    describe "passed a Fragment containing head and p" do
      it "returns a Fragment containing both head and body" do
        fragment = "<head><p>"
        expected = "<head></head><body><p></p></body>"
        actual = Nokogiri::HTML5::Inference.parse(fragment)

        assert_kind_of(Nokogiri::XML::NodeSet, actual)
        assert_equal(expected, actual.to_html)
      end
    end

    describe "multiple children" do
      it "parses correctly" do
        fragment = "<tr><td>hello</td></tr><tr><td>world</td></tr>"
        actual = Nokogiri::HTML5::Inference.parse(fragment)

        assert_kind_of(Nokogiri::XML::NodeSet, actual)
        assert_equal(fragment, actual.to_html)
      end

      describe "with pluck: false" do
        it "includes the additional sibling nodes created" do
          fragment = "<body><div>hello</div></body>"
          expected = "<head></head>#{fragment}"
          actual = Nokogiri::HTML5::Inference.parse(fragment, pluck: false)

          assert_kind_of(Nokogiri::XML::NodeSet, actual)
          assert_equal(expected, actual.to_html)
        end
      end
    end
  end
end

# -*- coding: utf-8 -*-
require 'coderay'

module CodeRay
  module Scanners

    class Keywords < Scanner

      include Streamable

      register_for :keywords
      title 'Keywords'

      def scan_tokens tokens, options

        keywords = options[:keywords]
        if !keywords
          r = self.string
          terminate
          if r.length > 0
            return [[r, :plain]]
          else
            return []
          end
        end

        regexp = /(.*?)(#{keywords.map {|k| Regexp.escape(k)}.join('|')})/im

        until eos?

          match = scan regexp

          if match
            pre = self[1]
            key = self[2]
            if pre and pre.length > 0
              tokens << [pre, :plain]
            end
            tokens << [key, :reserved]
          else
            r = rest
            if r and r.length > 0
              tokens << [r, :plain]
            end
            terminate
          end
        end

        tokens
      end

    end # class Keywords

  end
end

if $0 == __FILE__
  eval(DATA.read)
  require 'minitest/autorun'
end

__END__

require 'minitest/unit'

module CodeRay
  class KeywordsTest < MiniTest::Unit::TestCase
    def setup
      # do nothing
    end
    def teardown
      # do nothing
    end
    def test_empty
      assert_equal([],
                   Scanners[:keywords].new("").tokenize)
      assert_equal([[" ", :plain]],
                   Scanners[:keywords].new(" ").tokenize)
    end
    def test_no_keywords
      assert_equal([["foo bar baz", :plain]],
                   Scanners[:keywords].new("foo bar baz").tokenize)
      assert_equal([["foo\nbar\nbaz", :plain]],
                   Scanners[:keywords].new("foo\nbar\nbaz").tokenize)
    end
    def new_scanner(src, keywords)
      Scanners[:keywords].new(src, :keywords => keywords)
    end
    def test_one_keyword
      assert_equal([],
                   new_scanner("", ["hello"]).tokenize)
      assert_equal([[" ", :plain]],
                   new_scanner(" ", ["hello"]).tokenize)
      assert_equal([["foo", :plain]],
                   new_scanner("foo", ["hello"]).tokenize)
      assert_equal([["Hello", :reserved]],
                   new_scanner("Hello", ["hello"]).tokenize)
      assert_equal([["foo bar", :plain]],
                   new_scanner("foo bar", ["hello"]).tokenize)
      assert_equal([["Hello", :reserved], [" world!", :plain]],
                   new_scanner("Hello world!", ["hello"]).tokenize)
      assert_equal([["Say ", :plain], ["hello", :reserved]],
                   new_scanner("Say hello", ["hello"]).tokenize)
      assert_equal([["hello", :reserved], ["hello", :reserved]],
                   new_scanner("hellohello", ["hello"]).tokenize)
      assert_equal([["Hello", :reserved], ["Hello", :reserved]],
                   new_scanner("HelloHello", ["hello"]).tokenize)
      assert_equal([["hello", :reserved], ["HELLO", :reserved]],
                   new_scanner("helloHELLO", ["hello"]).tokenize)
      assert_equal([["hello", :reserved], ["hello", :reserved], ["hello", :reserved]],
                   new_scanner("hellohellohello", ["hello"]).tokenize)
      assert_equal([["hello", :reserved], ["Hello", :reserved], ["HELLO", :reserved]],
                   new_scanner("helloHelloHELLO", ["hello"]).tokenize)
      assert_equal([["A \"", :plain], ["Hello", :reserved],
                    [" world\" program is a computer program that prints out \"", :plain],
                    ["Hello", :reserved], [" world\" on a display device.", :plain]],
                   new_scanner('A "Hello world" program is a computer program that prints out "Hello world" on a display device.', ["hello"]).tokenize)
    end
    def test_two_keywords
      assert_equal([["A \"", :plain], ["Hello", :reserved], [" ", :plain], ["world", :reserved],
                    ["\" program is a computer program that prints out \"", :plain],
                    ["Hello", :reserved], [" ", :plain],
                    ["world", :reserved],
                    ["\" on a display device.", :plain]],
                   new_scanner('A "Hello world" program is a computer program that prints out "Hello world" on a display device.', ["hello", "world"]).tokenize)
    end
    def test_three_keywords
      assert_equal([["d", :plain], ["*", :reserved], ["d = (x1 ", :plain], ["-", :reserved],
                    [" x2)", :plain], ["*", :reserved], ["(x1 ", :plain], ["-", :reserved],
                    [" x2) ", :plain], ["+", :reserved], [" (y1 ", :plain], ["-", :reserved],
                    [" y2)", :plain], ["*", :reserved], ["(y1 ", :plain], ["-", :reserved],
                    [" y2)", :plain]],
                   new_scanner('d*d = (x1 - x2)*(x1 - x2) + (y1 - y2)*(y1 - y2)', ["+", "-", "*"]).tokenize)
    end
  end
end

# -*- coding: utf-8 -*-
require 'coderay'

module CodeRay
  module Scanners

    class Hello < Scanner

      include Streamable
      
      register_for :hello
      title 'Hello'

      def scan_tokens tokens, options
        keyword = 'hello'

        until eos?
          
          match = nil

          if match = scan(/(.*?)(#{keyword})/i)
            tokens << [self[1], :plain] unless self[1].length <= 0
            tokens << [self[2], :reserved]
          else
            tokens << [rest, :plain]
            terminate
          end
        end
        
        tokens
      end

    end # class Hello

  end
end

if $0 == __FILE__
  eval(DATA.read)
  require 'minitest/autorun'
end

__END__

require 'minitest/unit'

module CodeRay
  
  class HelloTest < MiniTest::Unit::TestCase
    def setup
      # do nothing
    end
    def teardown
      # do nothing
    end
    def test_empty
      assert_equal([],
                   Scanners[:hello].new("").tokenize)
      assert_equal([[" ", :plain]],
                   Scanners[:hello].new(" ").tokenize)
    end
    def test_word
      assert_equal([["foo", :plain]],
                   Scanners[:hello].new("foo").tokenize)
      assert_equal([["Hello", :reserved]],
                   Scanners[:hello].new("Hello").tokenize)
    end
    def test_two_words
      assert_equal([["foo bar", :plain]],
                   Scanners[:hello].new("foo bar").tokenize)
      assert_equal([["Hello", :reserved], [" world!", :plain]],
                   Scanners[:hello].new("Hello world!").tokenize)
      assert_equal([["Say ", :plain], ["hello", :reserved]],
                   Scanners[:hello].new("Say hello").tokenize)
    end
    def test_dup
      assert_equal([["hello", :reserved], ["hello", :reserved]],
                   Scanners[:hello].new("hellohello").tokenize)
      assert_equal([["Hello", :reserved], ["Hello", :reserved]],
                   Scanners[:hello].new("HelloHello").tokenize)
      assert_equal([["hello", :reserved], ["HELLO", :reserved]],
                   Scanners[:hello].new("helloHELLO").tokenize)
      assert_equal([["hello", :reserved], ["hello", :reserved], ["hello", :reserved]],
                   Scanners[:hello].new("hellohellohello").tokenize)
      assert_equal([["hello", :reserved], ["Hello", :reserved], ["HELLO", :reserved]],
                   Scanners[:hello].new("helloHelloHELLO").tokenize)
    end
  end # class HelloTest

end

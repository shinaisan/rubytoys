# To test this crap:
# > ruby test_hexspeak.rb

module Hexspeak

  class Finder
    def hexspeakable?(word)
      raise NotImplementedError
    end
    def convert(word)
      raise NotImplementedError
    end
    def find_all(text)
      text.split(/\b/).find_all{|word| hexspeakable?(word)}.inject(Hash.new){|h, w| h[w] = convert(w); h}
    end
  end

  module Finders
    
    class Strict < Finder
      def hexspeakable?(word)
        word !~ /[^a-f]/i
      end
      def convert(word)
        word
      end
    end

    class Zero < Finder
      def hexspeakable?(word)
        word !~ /[^a-fo]/i
      end
      def convert(word)
        word.tr("Oo", "00")
      end
    end

    class ZeroOne < Finder
      attr_reader :one
      def initialize(one_init = 'i')
        self.one = one_init
      end
      def one=(str)
        str.downcase!
        str = 'i' if str != 'l'
        @one = str
      end
      def hexspeakable?(word)
        word !~ /[^a-fo#{one}]/i
      end
      def convert(word)
        word.tr("Oo#{one.upcase}#{one}", "0011")
      end
    end

    class Greedy < ZeroOne
      def initialize(one_init = 'i')
        super(one_init)
      end
      def hexspeakable?(word)
        word !~ /[^a-g#{one}ostz]/i
      end
      def convert(word)
        word.tr("Gg#{one.upcase}#{one}OoSsTtZz", "991100557722")
      end
    end

  end

end

module Ngram

  # Calculate similarity of two strings by the N-gram method.
  def self.ngram_similarity(str1, str2, n)
    if n <= 0
      return 0
    end
    # Balance the disadvantage of characters at edges by padding
    padding = " " * (n - 1)
    str1 = padding + str1 + padding
    str2 = padding + str2 + padding
    h1 = ngram_hash(str1, n)
    h2 = ngram_hash(str2, n)
    h3 = {}
    h1.each_pair do |k, v1|
      v2 = h2[k]
      if !v2.nil?
        h3[k] = v1 + v2
      end
    end
    total = (h1.size + h2.size - h3.size)
    if total == 0
      0
    else
      h3.size.to_f / (h1.size + h2.size - h3.size).to_f
    end
  end

  # Enumerate all n-letter chunks from a given string
  # and return a hash from a n-letter chunk to its frequency.
  def self.ngram_hash(str, n)
    h = {}
    if n <= 0
      return h
    end
    limit = str.length - n
    for i in 0..limit
      key = str.slice(i, n)
      h[key] = (h[key] || 0) + 1
    end
    h
  end

  # Trigram
  def self.trigram_similarity(str1, str2)
    ngram_similarity(str1, str2, 3)
  end

end

if $0 == __FILE__
  eval(DATA.read)
  require 'minitest/autorun'
end

__END__
require 'minitest/unit'

module Ngram

  class NgramTest < MiniTest::Unit::TestCase
    def setup
      # do nothing
    end
    def teardown
      # do nothing
    end
    def test_zero
      assert_equal({}, Ngram::ngram_hash("", 0))
      assert_equal({}, Ngram::ngram_hash("foo", 0))
      assert_equal(0, Ngram::ngram_similarity("foo", "bar", 0))
      assert_equal(0, Ngram::ngram_similarity("foo", "bar", -1))
    end
    def test_empty
      assert_equal({}, Ngram::ngram_hash("", 3))
      assert_equal({}, Ngram::ngram_hash("foo", 4))
      assert_equal(0, Ngram::ngram_similarity("foo", "bar", 4))
    end
    def test_very_short
      assert_equal({"a" => 1}, Ngram::ngram_hash("a", 1))
      assert_equal({"a" => 2}, Ngram::ngram_hash("aa", 1))
      assert_equal({"a" => 1, "b" => 1}, Ngram::ngram_hash("ab", 1))
      assert_equal({"ab" => 1}, Ngram::ngram_hash("ab", 2))
      assert_equal(0, Ngram::ngram_similarity("a", "b", 1))
      assert_equal(1.0, Ngram::ngram_similarity("a", "a", 1))
      assert_equal(0.5, Ngram::ngram_similarity("ab", "aa", 1))
      assert_equal(1.0, Ngram::ngram_similarity("ab", "ab", 1))
      assert_equal(0.2, Ngram::ngram_similarity("ab", "aa", 2))
      assert_equal(1.0, Ngram::ngram_similarity("ab", "ab", 2))
    end
    def test_short
      assert_equal({"a" => 1, "b" => 1, "c" => 1}, Ngram::ngram_hash("abc", 1))
      assert_equal({"ab" => 1, "bc" => 1}, Ngram::ngram_hash("abc", 2))
      assert_equal(0.5, Ngram::ngram_similarity("abc", "bcd", 1))
      assert_equal(1.0 / 7.0, Ngram::ngram_similarity("abc", "bcd", 2))
      assert_equal(0.0, Ngram::ngram_similarity("abc", "bcd", 3))
    end
    def test_brown_fox
      s1 = "The quick brown fox jumps over the lazy dog" # 44 trigrams
      s2 = "The quick brown fox jumped over the lazy dogs" # 46 trigrams
      # 39 common trigrams
      assert_equal(39.0 / 51.0, Ngram::trigram_similarity(s1, s2))
    end
  end

end

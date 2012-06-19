# -*- coding: utf-8 -*-
module Ngram

  # Calculate similarity of two strings by the N-gram method.
  def self.ngram_similarity(str1, str2, n)
    h = ngram_similarities([str1, str2], n)
    if h.nil?
      0.0
    else
      h[str1][str2]
    end
  end

  # Construct a mapping from a pair of strings to their N-gram similarity
  #   allowing duplicate entries like ["a", "b"] => x and ["b", "a"] => y for convenience.
  def self.ngram_similarities(str_list, n)
    if n <= 0
      return nil
    end
    # Resulting table
    result = {}
    # Balance the disadvantage of characters at edges by padding
    padding = " " * (n - 1)
    # Iterate through all the pairs including duplicates.
    str_list.each do |str1|
      h1 = ngram_hash((padding + str1 + padding).downcase, n)
      result1 = result[str1] = {}
      str_list.each do |str2|
        inverse = ((r2 = result[str2]) && r2[str1])
        if (str1 == str2)       # The same strings
          result1[str2] = 1.0
        elsif !inverse.nil?     # Already calculated?
          result1[str2] = inverse
        else
          h2 = ngram_hash((padding + str2 + padding).downcase, n)
          h3 = {}
          h1.each_pair do |k, v1|
            v2 = h2[k]
            if !v2.nil?
              h3[k] = v1 + v2
            end
          end
          total = (h1.size + h2.size - h3.size)
          if total == 0
            result1[str2] = 0.0
          else
            result1[str2] = h3.size.to_f / total.to_f
          end
        end
      end
    end
    result
  end

  # Construct a mapping from a pair of strings to their N-gram similarity
  # and keep only top-m similarity pairs except for pairs of the same string.
  def self.ngram_similarities_top(str_list, n, m)
    mapping = ngram_similarities(str_list, n)
    # Delete pairs of the same string.
    mapping.keys.each do |str1|
      mapping[str1].delete(str1)
    end
    mapping.keys.each do |str1|
      # Sort by similarity in descending order.
      mapping[str1] = (mapping[str1].to_a.sort {|a, b| b[1] - a[1]})[0...m]
    end
    # The result is a Hash of Hash.
    mapping.keys.each do |str1|
      sorted = mapping[str1]
      m1 = mapping[str1] = {}
      for str2, sim in sorted
        m1[str2] = sim
      end
    end
    mapping
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
      s1 = "The quick brown fox jumps over the lazy dog" # 42 trigrams
      s2 = "The quick brown fox jumped over the lazy dogs" # 44 trigrams
      # 37 common trigrams
      assert_equal(37.0 / 49.0, Ngram::trigram_similarity(s1, s2))
    end
    def test_words
      words = ["ngram", "process", "program", "processing", "trigram"]
      assert_equal({
                     "ngram" => {"ngram" => 1.0, "process" => 0.0, "program" => 4.0 / 12.0, "processing" => 0.0, "trigram" => 4.0 / 12.0},
                     "process" => {"ngram" => 0.0, "process" => 1.0, "program" => 3.0 / 15.0, "processing" => 7.0 / 14.0, "trigram" => 0.0},
                     "program" => {"ngram" => 4.0 / 12.0, "process" => 3.0 / 15.0, "program" => 1.0, "processing" => 3.0 / 18.0, "trigram" => 4.0 / 14.0},
                     "processing" => {"ngram" => 0.0, "process" => 7.0 / 14.0, "program" => 3.0 / 18.0, "processing" => 1.0, "trigram" => 0.0},
                     "trigram" => {"ngram" => 4.0 / 12.0, "process" => 0.0, "program" => 4.0 / 14.0, "processing" => 0.0, "trigram" => 1.0}
                   },
                   Ngram::ngram_similarities(words, 3))
      assert_equal({
                     "ngram" => {"program" => 4.0 / 12.0, "trigram" => 4.0 / 12.0},
                     "process" => {"program" => 3.0 / 15.0, "processing" => 7.0 / 14.0},
                     "program" => {"ngram" => 4.0 / 12.0, "trigram" => 4.0 / 14.0},
                     "processing" => {"process" => 7.0 / 14.0, "program" => 3.0 / 18.0},
                     "trigram" => {"ngram" => 4.0 / 12.0, "program" => 4.0 / 14.0}
                   },
                   Ngram::ngram_similarities_top(words, 3, 2))
    end
  end

end

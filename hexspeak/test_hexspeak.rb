require 'minitest/unit'

load 'hexspeak.rb'

module Hexspeak  
  class TestFinders < MiniTest::Unit::TestCase
    def setup
      # do nothing
    end
    def teardown
      # do nothing
    end
    def test_Strict
      assert_equal({}, Finders::Strict.new.find_all("foo"))
      assert_equal({"dead" => "dead"}, Finders::Strict.new.find_all("dead"))
      assert_equal({"bad" => "bad", "cafe" => "cafe", "babe" => "babe"},
                   Finders::Strict.new.find_all("I ate bad food at cafe babe and feel no good."))
    end
    def test_Zero
      assert_equal({}, Finders::Zero.new.find_all("bar"))
      assert_equal({"foo" => "f00"}, Finders::Zero.new.find_all("foo"))
      assert_equal({"dead" => "dead", "beef" => "beef"}, Finders::Strict.new.find_all("dead beef"))
      assert_equal({"bad" => "bad", "food" => "f00d", "cafe" => "cafe", "babe" => "babe"},
                   Finders::Zero.new.find_all("I ate bad food at cafe babe and feel no good."))
    end
    def test_ZeroOne
      assert_equal({}, Finders::ZeroOne.new.find_all("fool"))
      assert_equal({"fool" => "f001"}, Finders::ZeroOne.new('l').find_all("fool"))
      assert_equal({"idea" => "1dea"}, Finders::ZeroOne.new('i').find_all("idea"))
      assert_equal({}, Finders::ZeroOne.new('l').find_all("idea"))
      assert_equal({"I" => "1", "bad" => "bad", "food" => "f00d", "cafe" => "cafe", "babe" => "babe"},
                   Finders::ZeroOne.new.find_all("I ate bad food at cafe babe and feel no good."))
      assert_equal({"bad" => "bad", "food" => "f00d", "cafe" => "cafe", "babe" => "babe", "feel" => "fee1"},
                   Finders::ZeroOne.new('l').find_all("I ate bad food at cafe babe and feel no good."))
    end
    def test_Greedy
      assert_equal({"CISC" => "C15C"}, Finders::Greedy.new.find_all("CISC"))
      assert_equal({}, Finders::Greedy.new('l').find_all("CISC"))
      assert_equal({"false" => "fa15e"}, Finders::Greedy.new('l').find_all("false"))
      assert_equal({}, Finders::Greedy.new('i').find_all("false"))
      assert_equal({"booze" => "b002e"}, Finders::Greedy.new.find_all("booze"))
      assert_equal({"I" => "1", "ate" => "a7e", "bad" => "bad", "food" => "f00d", "at" => "a7", "cafe" => "cafe", "babe" => "babe", "good" => "900d"},
                   Finders::Greedy.new.find_all("I ate bad food at cafe babe and feel no good."))
      assert_equal({"ate" => "a7e", "bad" => "bad", "food" => "f00d", "at" => "a7", "cafe" => "cafe", "babe" => "babe", "feel" => "fee1", "good" => "900d"},
                   Finders::Greedy.new('l').find_all("I ate bad food at cafe babe and feel no good."))
    end
  end

end

MiniTest::Unit.autorun

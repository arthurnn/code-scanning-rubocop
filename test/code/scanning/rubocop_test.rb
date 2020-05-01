require "test_helper"

class Code::Scanning::RubocopTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Code::Scanning::Rubocop::VERSION
  end

  def test_it_does_something_useful
    assert false
  end
end

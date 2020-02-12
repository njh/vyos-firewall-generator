require "minitest/autorun"
require "vyos-config/defaults"

class TestVyosConfigDefaults < Minitest::Test
  def setup
    @config = VyOSConfig::Defaults.new
  end

  def test_equal_to_file
    filepath = File.join(File.dirname(__FILE__), 'config.boot.default')
    expected = File.read(filepath)
    assert_equal expected, @config.to_s
  end
end

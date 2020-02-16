require "test_helper"
require "vyos-generate-firewall"

class TestVyOSFirewallGenerator < Minitest::Test
  def setup
    @generator = VyOSFirewallGenerator.new
  end

  def test_detect_ipvers_ipv4_private
    assert_equal(
      :ipv4,
      @generator.detect_ipvers('192.168.1.1')
    )
  end

  def test_detect_ipvers_ipv4_range
    assert_equal(
      :ipv4,
      @generator.detect_ipvers('90.155.3.0/24')
    )
  end

  def test_detect_ipvers_ipv6_global
    assert_equal(
      :ipv6,
      @generator.detect_ipvers('2001:0db8:85a3:0000:0000:8a2e:0370:7334')
    )
  end

  def test_detect_ipvers_ipv6_linklocal
    assert_equal(
      :ipv6,
      @generator.detect_ipvers('fe80::74e6:b5f3:fe92:830e')
    )
  end

  def test_detect_ipvers_ipv6_localhost
    assert_equal(
      :ipv6,
      @generator.detect_ipvers('::1')
    )
  end

  def test_detect_ipvers_plain_hostname
    assert_nil @generator.detect_ipvers('foobar')
  end
  
  def test_generate_global_stateful
    @generator.generate_global_stateful
    assert_equal fixture('global_stateful.txt'), @generator.config.to_s
  end

  def test_generate_simple_no_rules_config
    @generator.input = json_fixture('simple_no_rules.json')
    assert_equal fixture('simple_no_rules.txt'), @generator.to_s
  end

  def test_generate_simple_no_rules_commands
    @generator.input = json_fixture('simple_no_rules.json')
    assert_equal fixture('simple_no_rules-commands.txt'), @generator.commands_string
  end

  def test_generate_four_zones_no_rules_config
    @generator.input = json_fixture('four_zones_no_rules.json')
    assert_equal fixture('four_zones_no_rules.txt'), @generator.to_s
  end

  def test_generate_four_zones_no_rules_commands
    @generator.input = json_fixture('four_zones_no_rules.json')
    assert_equal fixture('four_zones_no_rules-commands.txt'), @generator.commands_string
  end
end

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

  def test_select_ipvers_ipv4
    assert_equal ['127.0.0.1'], @generator.select_ipvers(['127.0.0.1', '::1'], :ipv4)
  end

  def test_select_ipvers_ipv6
    assert_equal ['::1'], @generator.select_ipvers(['127.0.0.1', '::1'], :ipv6)
  end

  def test_select_ipvers_invalid
    assert_equal [], @generator.select_ipvers(['foobar', '1.2'], :ipv6)
  end

  def test_resolve_alias_ipv4
    @generator.input = json_fixture('simple.json')
    assert_equal ['203.0.113.40'], @generator.resolve_alias('server1', :ipv4)
  end

  def test_resolve_alias_ipv6
    @generator.input = json_fixture('simple.json')
    assert_equal ['2001:0DB8:DEAD::40'], @generator.resolve_alias('server1', :ipv6)
  end

  def test_resolve_alias_ipv4_only
    @generator.input = json_fixture('simple.json')
    assert_equal(
      ['203.0.113.45', '203.0.113.46'],
      @generator.resolve_alias('server2', :ipv4)
    )
  end

  def test_resolve_alias_ipv6_only
    @generator.input = json_fixture('simple.json')
    assert_equal(
      ['2001:0DB8:DEAD::60'],
      @generator.resolve_alias('server3', :ipv6)
    )
  end

  def test_resolve_multiple_alias_ipv4
    @generator.input = json_fixture('simple.json')
    assert_equal(
      ["203.0.113.40", "203.0.113.45", "203.0.113.46"],
      @generator.resolve_alias(['server1', 'server2', 'server3'], :ipv4)
    )
  end

  def test_resolve_multiple_alias_ipv6
    @generator.input = json_fixture('simple.json')
    assert_equal(
      ["2001:0DB8:DEAD::40", "2001:0DB8:DEAD::60"],
      @generator.resolve_alias(['server1', 'server2', 'server3'], :ipv6)
    )
  end

  def test_resolve_address_not_alias_ipv4
    @generator.input = json_fixture('simple.json')
    assert_equal(
      ["127.0.0.1"],
      @generator.resolve_alias('127.0.0.1', :ipv4)
    )
  end

  def test_resolve_address_not_alias_ipv6
    @generator.input = json_fixture('simple.json')
    assert_equal(
      ["2001:0DB8:DEAD::1"],
      @generator.resolve_alias(['127.0.0.1', '2001:0DB8:DEAD::1'], :ipv6)
    )
  end

  def test_resolve_unknown_alias
    @generator.input = json_fixture('simple.json')
    assert_raises {@generator.resolve_alias('uknown-alias', :ipv4)}
  end

  def test_port_string_string
    result = false
    @generator.port_string('53') {|str| result = str}
    assert_equal '53', result
  end

  def test_port_string_integer
    result = false
    @generator.port_string(22) {|str| result = str}
    assert_equal '22', result
  end

  def test_port_string_array
    result = false
    @generator.port_string([80,443]) {|str| result = str}
    assert_equal '80,443', result
  end

  def test_port_string_range
    result = false
    @generator.port_string(16384..16482) {|str| result = str}
    assert_equal '16384-16482', result
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

  def test_generate_simple_config
    @generator.input = json_fixture('simple.json')
    assert_equal fixture('simple.txt'), @generator.to_s
  end

  def test_generate_simple_commands
    @generator.input = json_fixture('simple.json')
    assert_equal fixture('simple-commands.txt'), @generator.commands_string
  end
end

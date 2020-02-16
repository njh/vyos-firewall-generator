require "test_helper"
require "vyos-generate-firewall"

class TestVyOSFirewallGenerator < Minitest::Test
	def setup
	  @generator = VyOSFirewallGenerator.new
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

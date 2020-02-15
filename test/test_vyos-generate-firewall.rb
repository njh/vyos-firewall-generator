require "test_helper"
require "vyos-generate-firewall"

class TestVyOSFirewallGenerator < Minitest::Test
  def test_generate_simple_no_rules_config
    input = json_fixture('simple_no_rules.json')
    generator = VyOSFirewallGenerator.new(input)
    assert_equal fixture('simple_no_rules.txt'), generator.to_s
  end

  def test_generate_simple_no_rules_commands
    input = json_fixture('simple_no_rules.json')
    generator = VyOSFirewallGenerator.new(input)
    assert_equal fixture('simple_no_rules-commands.txt'), generator.commands_string
  end
end

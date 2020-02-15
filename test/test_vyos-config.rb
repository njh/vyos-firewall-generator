require "test_helper"
require "vyos-config"

# Test suite for testing generating VyOS configuration
#
# See also: https://github.com/vyos/vyos-1x/blob/current/tests/data/config.valid
#

class TestVyosConfig < Minitest::Test
  def setup
    @config = VyOSConfig.new
  end

  def test_config_top_level_leaf_node
    @config.top_level_leaf_node = 'foo'
    assert_equal "top-level-leaf-node foo\n", @config.to_s
  end

  def test_config_empty_node
    @config.empty_node.empty
    assert_equal "empty-node {\n}\n", @config.to_s
  end

  def test_config_top_level_valueless_node
    @config.top_level_valueless_node
    assert_equal "top-level-valueless-node\n", @config.to_s
  end

  def test_config_integer
    @config.service.ssh.port = 22
    assert_equal(
      "service {\n" +
      "    ssh {\n" +
      "        port 22\n" +
      "    }\n" +
      "}\n", @config.to_s
    )
  end

  def test_config_with_tag
    @config.system.console.device('ttyS0').speed = '115200'
    assert_equal(
      "system {\n" +
      "    console {\n" +
      "        device ttyS0 {\n" +
      "            speed 115200\n" +
      "        }\n" +
      "    }\n" +
      "}\n", @config.to_s
    )
  end

  def test_underscore_to_hyphen
    @config.system.config_management.commit_revisions = 100
    assert_equal(
      "system {\n" +
      "    config-management {\n" +
      "        commit-revisions 100\n" +
      "    }\n" +
      "}\n", @config.to_s
    )
  end

  def test_config_multiple_same_name
    @config.interfaces.ethernet('eth0').address = '192.0.2.1/24'
    @config.interfaces.ethernet('eth0').address = '2001:db8::ffff/64'
    assert_equal(
      "interfaces {\n" +
      "    ethernet eth0 {\n" +
      "        address '192.0.2.1/24'\n" +
      "        address '2001:db8::ffff/64'\n" +
      "    }\n" +
      "}\n", @config.to_s
    )
  end

  def test_config_empty_string
    @config.system.login.user('vyos').authentication.plaintext_password = ''
    assert_equal(
      "system {\n" +
      "    login {\n" +
      "        user vyos {\n" +
      "            authentication {\n" +
      "                plaintext-password ''\n" +
      "            }\n" +
      "        }\n" +
      "    }\n" +
      "}\n", @config.to_s
    )
  end

  def test_config_subsection
    @config.service.ssh.port = 22
    assert_equal(
      "ssh {\n" +
      "    port 22\n" +
      "}\n", @config.service.to_s
    )
  end


  def test_commands_top_level_leaf_node
    @config.top_level_leaf_node = 'foo'
    assert_equal(
      [
        "set top-level-leaf-node foo"
      ],
      @config.commands
    )
  end

  def test_commands_empty_node
    @config.empty_node.empty
    assert_equal(
      [
        "set empty-node"
      ],
      @config.commands
    )
  end

  def test_commands_top_level_valueless_node
    @config.top_level_valueless_node
    assert_equal(
      [
        "set top-level-valueless-node"
      ],
      @config.commands
    )
  end

  def test_commands_simple
    @config.service.ssh.port = 22
    assert_equal(
      [
        "set service ssh port 22"
      ],
      @config.commands
    )
  end

  def test_commands_multi
    @config.system.config_management.commit_revisions = 100
    @config.system.login.user('vyos').authentication.plaintext_password = ''
    @config.service.ssh.port = 22
    assert_equal(
      [
        "set system config-management commit-revisions 100",
        "set system login user vyos authentication plaintext-password ''",
        "set service ssh port 22"
      ],
      @config.commands
    )
  end

  def test_commands_multiple_same_name
    @config.interfaces.ethernet('eth0').address = '192.0.2.1/24'
    @config.interfaces.ethernet('eth0').address = '2001:db8::ffff/64'
    assert_equal(
      [
        "set interfaces ethernet eth0 address '192.0.2.1/24'",
        "set interfaces ethernet eth0 address '2001:db8::ffff/64'",
      ],
      @config.commands
    )
  end
end

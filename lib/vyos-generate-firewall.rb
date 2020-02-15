require 'vyos-config'
require 'titleize'

class VyOSFirewallGenerator
  attr_accessor :input
  attr_accessor :config

  def initialize(input)
    @config = VyOSConfig.new
    @input = input
  end

  def aliases
    input['aliases']
  end

  def zones
    input['zones']
  end

  def zone_names
    zones.keys
  end

  def generate_default_action(name, ipvers, default_action)
    raise "default_action is not set for #{name}" if default_action.nil?
    if ipvers == :ipv6
      config.firewall.ipv6_name(name).default_action = default_action
    else
      config.firewall.name(name).default_action = default_action
    end
  end

  def generate_global_stateful
    config.firewall.state_policy.established.action = :accept
    config.firewall.state_policy.related.action = :accept
    config.firewall.state_policy.invalid.action = :drop
  end

  def generate
    zones.each_pair do |zone_name, zone_data|
      description = zone_data['description'] || "#{zone_name.to_s.titleize} Zone"
      config.zone_policy.zone(zone_name).description = description
      if zone_data['interfaces'].nil? || zone_data['interfaces'].empty?
        config.zone_policy.zone(zone_name).local_zone
      else
        zone_data['interfaces'].each do |interface|
          config.zone_policy.zone(zone_name).interface = interface
        end
      end

      zone_names.each do |from_zone|
        next if zone_name == from_zone
        key = "#{zone_name}-from-#{from_zone}"

        generate_default_action("#{key}-v4", :ipv4, input['default-actions'][key])
        generate_default_action("#{key}-v6", :ipv6, input['default-actions'][key])
        config.zone_policy.zone(zone_name).from(from_zone).firewall.name = "#{key}-v4"
        config.zone_policy.zone(zone_name).from(from_zone).firewall.ipv6_name = "#{key}-v6"
      end
    end
  end

  def commands
    generate
    config.commands
  end

  def commands_string
    commands.join("\n")+"\n"
  end

  def to_s
    generate
    config.to_s
  end
end

#!/usr/bin/env ruby

require 'json'
require 'titleize'


config = JSON.parse(File.read('example/firewall.json'))



def puts_filewall_rules(name, protocol, default_action)
  raise "default_action is not set for #{name}" if default_action.nil?
  name_dec = (protocol == 'ipv6' ? 'ipv6-name' : 'name')
  puts "set firewall #{name_dec} #{name} default-action #{default_action}"
end


puts "# Globally enable stateful firewall"
puts "set firewall state-policy established action accept"
puts "set firewall state-policy related action accept"
puts "set firewall state-policy invalid action drop"
puts

config['zones'].each_pair do  |zone_name, zone_config|
  puts "# Zone #{zone_name}"
  description = zone_config['description'] || "#{zone_name.titleize} Zone"
  puts "set zone-policy zone #{zone_name} description '#{description}'"
  if zone_config['interfaces'].nil? || zone_config['interfaces'].empty?
    puts "set zone-policy zone #{zone_name} local-zone"
  else
    zone_config['interfaces'].each do |interface|
      puts "set zone-policy zone #{zone_name} interface #{interface}"
    end
  end

  config['zones'].keys.each do |from_zone|
    next if zone_name == from_zone
    key = "#{zone_name}-from-#{from_zone}"
    
    puts_default_action("#{key}-v4", 'ipv4', config['default-actions'][key])
    puts_default_action("#{key}-v6", 'ipv6', config['default-actions'][key])
    puts "set zone-policy zone #{zone_name} from #{from_zone} firewall name #{key}-v4"
    puts "set zone-policy zone #{zone_name} from #{from_zone} firewall ipv6-name #{key}-v6"
    puts
  end

  puts
end

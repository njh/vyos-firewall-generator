#!/usr/bin/env ruby

require 'titleize'

zones = {
  'PRIVATE' => ['eth0', 'eth1'],
  'PUBLIC' => ['pppoe0'],
  'DMZ' => ['eth2'],
  'LOCAL' => []
}

default_actions = {
   'PRIVATE-from-PUBLIC' => 'reject',
   'PRIVATE-from-DMZ' => 'accept',
   'PRIVATE-from-LOCAL' => 'reject',
   'PUBLIC-from-PRIVATE' => 'accept',
   'PUBLIC-from-DMZ' => 'accept',
   'PUBLIC-from-LOCAL' => 'accept',
   'DMZ-from-PRIVATE' => 'accept',
   'DMZ-from-PUBLIC' => 'reject',
   'DMZ-from-LOCAL' => 'reject',
   'LOCAL-from-PRIVATE' => 'accept',
   'LOCAL-from-PUBLIC' => 'reject',
   'LOCAL-from-DMZ' => 'reject',
}



def puts_filewall_rules(name, protocol, default_action)
  raise "default_action is not set for #{name}" if default_action.nil?
  name_dec = (protocol == 'ipv6' ? 'ipv6-name' : 'name')
  puts "set firewall #{name_dec} #{name} default-action #{default_action}"
  puts "set firewall #{name_dec} #{name} rule 1010 action accept"
  puts "set firewall #{name_dec} #{name} rule 1010 state established enable"
  puts "set firewall #{name_dec} #{name} rule 1010 state related enable"
  puts "set firewall #{name_dec} #{name} rule 1020 action drop"
  puts "set firewall #{name_dec} #{name} rule 1020 state invalid enable"
end

zones.each_pair do  |zone, interfaces|
  puts "# Zone #{zone}"
  puts "set zone-policy zone #{zone} description '#{zone.titleize} Zone'"
  if interfaces.empty?
    puts "set zone-policy zone #{zone} local-zone"
  else
    interfaces.each do |interface|
      puts "set zone-policy zone #{zone} interface #{interface}"
    end
  end

  zones.keys.each do |from_zone|
    next if zone == from_zone
    key = "#{zone}-from-#{from_zone}"
    
    puts_filewall_rules("#{key}-v4", 'ipv4', default_actions[key])
    puts_filewall_rules("#{key}-v6", 'ipv6', default_actions[key])
    puts "set zone-policy zone #{zone} from #{from_zone} firewall name #{key}-v4"
    puts "set zone-policy zone #{zone} from #{from_zone} firewall ipv6-name #{key}-v6"
    puts
  end

  puts
end

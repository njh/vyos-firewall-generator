require 'vyos-config'

# A VyOS configuration initialised with the VyOS default config
class VyOSConfig::Defaults < VyOSConfig
  def initialize
    super
    set_defaults
  end

  def set_defaults
    self.system.host_name = 'vyos'
    self.system.login.user('vyos').authentication.encrypted_password =
      '$6$QxPS.uk6mfo$9QBSo8u1FkH16gMyAVhus6fU3LOzvLR9Z9.82m3tiHFAxTtIkhaZSWssSgzt4v4dGAL8rhVQxTg0oAG9/q11h/'
    self.system.login.user('vyos').authentication.plaintext_password = ''
    self.system.login.user('vyos').level = 'admin'
    self.system.syslog.global.facility('all').level = 'notice'
    self.system.syslog.global.facility('protocols').level = 'debug'
    self.system.ntp.server = '0.vyos.pool.ntp.org'
    self.system.ntp.server = '1.vyos.pool.ntp.org'
    self.system.ntp.server = '2.vyos.pool.ntp.org'
    self.system.console.device('ttyS0').speed = '115200'
    self.system.config_management.commit_revisions = 100
    interfaces.loopback('lo').empty
  end
end

module GenesisCollector
  module IPMI

    def collect_ipmi
      @payload[:ipmi] = {
        address: read_ipmi_lan_attribute('IP Address'),
        netmask: read_ipmi_lan_attribute('Subnet Mask'),
        mac: read_ipmi_lan_attribute('MAC Address'),
        gateway: read_ipmi_lan_attribute('Default Gateway IP')
      }
    end

    private

    def read_ipmi_lan_attribute(key)
      @ipmi_lan_output ||= shellout_with_timeout('ipmitool lan print', 10)
      match = @ipmi_lan_output.match(/#{key}\s*:\s*(\S+)$/)
      raise "IPMI lan print output missing key: #{key}" if match.nil?
      match[1]
    end

    def read_ipmi_fru(key)
      @ipmi_fru_output ||= shellout_with_timeout('ipmitool fru')
      match = @ipmi_fru_output.match(/#{key}\s*:\s*(\S+)$/)
      raise "IPMI fru output missing key: #{key}" if match.nil?
      match[1]
    end

    def read_ipmi_fw(key)
      @ipmi_fw_output ||= shellout_with_timeout('ipmitool mc info')
      match = @ipmi_fw_output.match(/#{key}\s*:\s*(\S+)$/)
      raise "IPMI FW output missing key: #{key}" if match.nil?
      match[1]
    end
  end
end

require 'pry'
require 'pp'
require 'net/scp'
require 'net/netconf/jnpr'
require 'junos-ez/stdlib'
     
# login information for NETCONF session 
unless ARGV[0]
  puts "You must specify a target"
  exit 1
end

login = { :target => ARGV[0], :username => 'jeremy',  :password => 'jeremy1',  }

## create a NETCONF object to manage the device and open the connection ...

ndev = Netconf::SSH.new( login )
print "Connecting to device #{login[:target]} ... "
ndev.open
puts "OK!"

binding.pry

## attach our private & utils that we need ...

Junos::Ez::Provider( ndev )
Junos::Ez::RE::Utils( ndev, :re )
Junos::Ez::FS::Utils( ndev, :fs )
Junos::Ez::Config::Utils( ndev, :cu )

binding.pry

ndev.close

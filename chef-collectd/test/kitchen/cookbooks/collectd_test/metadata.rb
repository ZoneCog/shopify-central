name 'collectd_test'
license 'Apache 2.0'
version '0.1.0'
description 'Acceptance tests for collectd.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
maintainer 'Miah Johnson'
maintainer_email 'miah@chia-pet.org'

%w(apt ark build-essential logrotate runit yum).each { |cookbook| depends cookbook }

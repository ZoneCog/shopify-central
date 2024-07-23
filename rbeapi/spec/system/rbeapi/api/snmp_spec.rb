require 'spec_helper'

require 'rbeapi/client'
require 'rbeapi/api/snmp'

describe Rbeapi::Api::Snmp do
  subject { described_class.new(node) }

  let(:node) do
    Rbeapi::Client.config.read(fixture_file('dut.conf'))
    Rbeapi::Client.connect_to('dut')
  end

  describe '#get' do
    let(:keys) do
      [:location, :contact, :chassis_id, :source_interface]
    end

    it 'has the required key in the resource hash' do
      keys.each do |key|
        expect(subject.get).to include(key)
      end
    end
  end

  describe '#set_location' do
    before { node.config(['no snmp-server location']) }

    it 'configures the snmp location value' do
      expect(subject.get[:location]).to be_empty
      expect(subject.set_location(value: 'foo')).to be_truthy
      expect(subject.get[:location]).to eq('foo')
    end

    it 'negates the snmp location' do
      expect(subject.set_location(value: 'foo')).to be_truthy
      expect(subject.get[:location]).to eq('foo')
      expect(subject.set_location(enable: false)).to be_truthy
      expect(subject.get[:location]).to be_empty
    end

    it 'defaults the snmp location' do
      expect(subject.set_location(value: 'foo')).to be_truthy
      expect(subject.get[:location]).to eq('foo')
      expect(subject.set_location(default: true)).to be_truthy
      expect(subject.get[:location]).to be_empty
    end
  end

  describe '#set_contact' do
    before { node.config('no snmp-server contact') }

    it 'configures the snmp contact value' do
      expect(subject.get[:contact]).to be_empty
      expect(subject.set_contact(value: 'foo')).to be_truthy
      expect(subject.get[:contact]).to eq('foo')
    end

    it 'negates the snmp contact' do
      expect(subject.set_contact(value: 'foo')).to be_truthy
      expect(subject.get[:contact]).to eq('foo')
      expect(subject.set_contact(enable: false)).to be_truthy
      expect(subject.get[:contact]).to be_empty
    end

    it 'defaults the snmp contact' do
      expect(subject.set_contact(value: 'foo')).to be_truthy
      expect(subject.get[:contact]).to eq('foo')
      expect(subject.set_contact(default: true)).to be_truthy
      expect(subject.get[:contact]).to be_empty
    end
  end

  describe '#set_chassis_id' do
    before { node.config('no snmp-server chassis-id') }

    it 'configures the snmp chassis-id value' do
      expect(subject.get[:chassis_id]).to be_empty
      expect(subject.set_chassis_id(value: 'foo')).to be_truthy
      expect(subject.get[:chassis_id]).to eq('foo')
    end

    it 'negates the chassis id' do
      expect(subject.set_chassis_id(value: 'foo')).to be_truthy
      expect(subject.get[:chassis_id]).to eq('foo')
      expect(subject.set_chassis_id(enable: false)).to be_truthy
      expect(subject.get[:chassis_id]).to be_empty
    end

    it 'defaults the chassis id' do
      expect(subject.set_chassis_id(value: 'foo')).to be_truthy
      expect(subject.get[:chassis_id]).to eq('foo')
      expect(subject.set_chassis_id(default: true)).to be_truthy
      expect(subject.get[:chassis_id]).to be_empty
    end
  end

  describe '#set_source_interface' do
    before { node.config('no snmp-server source-interface') }

    it 'configures the snmp source-interface value' do
      expect(subject.get[:source_interface]).to be_empty
      expect(subject.set_source_interface(value: 'Loopback0')).to be_truthy
      expect(subject.get[:source_interface]).to eq('Loopback0')
    end

    it 'negates the snmp source-interface' do
      expect(subject.set_source_interface(value: 'Loopback0')).to be_truthy
      expect(subject.get[:source_interface]).to eq('Loopback0')
      expect(subject.set_source_interface(enable: false)).to be_truthy
      expect(subject.get[:source_interface]).to be_empty
    end

    it 'defaults the snmp source-interface' do
      expect(subject.set_source_interface(value: 'Loopback0')).to be_truthy
      expect(subject.get[:source_interface]).to eq('Loopback0')
      expect(subject.set_source_interface(default: true)).to be_truthy
      expect(subject.get[:source_interface]).to be_empty
    end
  end

  describe '#set_community_acl' do
    before do
      node.config(['no snmp-server community foo',
                   'no snmp-server community bar'])
    end

    it 'configures nil acl for snmp community foo and bar' do
      expect(subject.get[:communities]).to be_empty
      expect(subject.set_community_acl('foo')).to be_truthy
      expect(subject.get[:communities]['foo']).to eq(access: 'ro', acl: nil)
      expect(subject.set_community_acl('bar')).to be_truthy
      expect(subject.get[:communities]['bar']).to eq(access: 'ro', acl: nil)
    end

    it 'configures IPv4 acl for snmp community foo and bar' do
      expect(subject.get[:communities]).to be_empty
      expect(subject.set_community_acl('foo', value: 'eng')).to be_truthy
      expect(subject.get[:communities]['foo']).to eq(access: 'ro', acl: 'eng')
      expect(subject.set_community_acl('bar', value: 'eng')).to be_truthy
      expect(subject.get[:communities]['bar']).to eq(access: 'ro', acl: 'eng')
    end

    it 'negates the snmp community ACL for bar' do
      expect(subject.get[:communities]).to be_empty
      expect(subject.set_community_acl('foo', value: 'eng')).to be_truthy
      expect(subject.get[:communities]['foo']).to eq(access: 'ro', acl: 'eng')
      expect(subject.set_community_acl('bar', value: 'eng')).to be_truthy
      expect(subject.get[:communities]['bar']).to eq(access: 'ro', acl: 'eng')
      # Remove bar
      expect(subject.set_community_acl('bar', enable: false)).to be_truthy
      expect(subject.get[:communities]['bar']).to be_falsy
      # Make sure foo is still there
      expect(subject.get[:communities]['foo']).to eq(access: 'ro', acl: 'eng')
    end

    it 'defaults the snmp community ACL for bar' do
      expect(subject.get[:communities]).to be_empty
      expect(subject.set_community_acl('foo', value: 'eng')).to be_truthy
      expect(subject.get[:communities]['foo']).to eq(access: 'ro', acl: 'eng')
      expect(subject.set_community_acl('bar', value: 'eng')).to be_truthy
      expect(subject.get[:communities]['bar']).to eq(access: 'ro', acl: 'eng')
      # Default bar
      expect(subject.set_community_acl('bar', default: true)).to be_truthy
      expect(subject.get[:communities]['bar']).to be_falsy
      # Make sure foo is still there
      expect(subject.get[:communities]['foo']).to eq(access: 'ro', acl: 'eng')
    end
  end
end

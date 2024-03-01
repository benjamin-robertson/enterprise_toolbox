# frozen_string_literal: true

require 'spec_helper'
require 'facter'
require 'facter/puppet_enterprise_role'

describe :puppet_enterprise_role, type: :fact do
  subject(:fact) { Facter.fact(:puppet_enterprise_role) }

  output = <<-EOF
Notice: Contacting services for status information...

Primary: ip-10-8-0-168.ap-southeast-2.compute.internal
  Activity Service: Running, checked via https://ip-10-8-0-168.ap-southeast-2.compute.internal:4433/status/v1/services

Replica: ip-10-8-0-142.ap-southeast-2.compute.internal
  Activity Service: Running, checked via https://ip-10-8-0-142.ap-southeast-2.compute.internal:4433/status/v1/services

Compiler: ip-10-8-0-152.ap-southeast-2.compute.internal
  File Sync Client Service: Running, checked via https://ip-10-8-0-152.ap-southeast-2.compute.internal:8140/status/v1/services

Status at 2024-02-05 04:41:29 +0000
EOF

  before :each do
    # perform any action that should be run before every test

    Facter.clear
    Facter.add(:pe_version) {}
    allow(Facter.fact(:pe_version)).to receive(:value).and_return('2021.8.4')
    allow(Open3).to receive(:capture2).with('puppet infrastructure status').and_return([output, '0'])
  end

  describe 'primary server check' do
    it 'returns primary' do
      allow(Socket).to receive(:gethostname).and_return('ip-10-8-0-168.ap-southeast-2.compute.internal')
      expect(fact.value).to eq('Primary')
    end
  end

  describe 'replica server check' do
    it 'returns replica' do
      allow(Socket).to receive(:gethostname).and_return('ip-10-8-0-142.ap-southeast-2.compute.internal')
      expect(fact.value).to eq('Replica')
    end
  end

  describe 'compiler server check' do
    it 'returns complier' do
      allow(Socket).to receive(:gethostname).and_return('ip-10-8-0-152.ap-southeast-2.compute.internal')
      allow(Open3).to receive(:capture2).with('puppet infrastructure status').and_return([output, '1'])
      expect(fact.value).to eq('Compiler')
    end
  end
end

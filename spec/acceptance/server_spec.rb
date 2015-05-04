require 'spec_helper_acceptance'
require 'pry'

pp = <<-EOS
  include apt

  exec { 'apt-get update':
    command   => '/bin/true',
    unless    => '/usr/bin/apt-get update',
    loglevel  => 'info',
    logoutput => 'on_failure',
    before    => Class['splunk']
  }

  apt::source { 'fanduel':
    location => 'http://apt.east.fdbox.net',
    repos    => 'main',
    key      => {
      id     => '7CC084EB12087BED0EADB2466AA630653DFA4BD3',
      source => 'http://apt.east.fdbox.net/fanduelpkg.gpg.key',
    },
    before   => Exec['apt-get update'],
  }

  class { 'splunk::params':
    version      => '6.2.2',
    pkg_provider => 'apt',
  }
  class { 'splunk':
    splunkd_listen => '0.0.0.0',
  }

  splunk_transforms { 'hadoop severity regex':
    section => 'hadoop_severity',
    setting => 'REGEX',
    value   => '\\d',
    require => Service[splunk]
  }
  splunk_transforms { 'hadoop severity format':
    section => 'hadoop_severity',
    setting => 'FORMAT',
    value   => 'severity::$1',
    require => Service[splunk]
  }
EOS

describe 'setting up the server' do
  it 'should be able to set up a server' do
    apply_manifest(pp, catch_failures: true)
  end

  it 'should apply the manifest again and make no further changes' do
    apply_manifest(pp, catch_changes: true)
  end

  describe service('splunk') do
    it { should be_running }
  end

  describe port(9997) do
    it { should be_listening.on('0.0.0.0').with('tcp') }
  end

  describe port(8089) do
    it { should be_listening.on('0.0.0.0').with('tcp') }
  end

  describe port(8000) do
    it { should be_listening.on('0.0.0.0').with('tcp') }
  end

  describe file('/opt/splunk/etc/system/local/transforms.conf') do
    its(:content) { should match(/\[hadoop_severity\]\nFORMAT=severity::\$1\nREGEX=\\d/) }
  end
end

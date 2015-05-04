# Class: splunk::peer
#
# This class deploys Splunk as a peer (indexer) on Linux, Windows, Solaris 
# platforms.
#
# Parameters:
#
#   See splunk class for parameters.
#
# Actions:
#
#   Configures the Splunk server.conf file for cluster peer/slave mode.
#
# Requires: nothing
#
class splunk::peer
{
  include splunk

  # Export splunk peer resources
  # Will use in future forwarder outputs
  @@splunk_peer { "splunk_peer__${::fqdn}":
    host_name    => $::fqdn,
    logging_port => $splunk::params::logging_port
  }

  ini_setting {
    'splunk_replication_port':
      path    => "${splunk::params::server_confdir}/server.conf",
      section => "replication_port://${splunk::replication_port}",
      setting => 'disabled',
      value   => '0';
    'splunk_peer_node':
      path    => "${splunk::params::server_confdir}/server.conf",
      section => 'clustering',
      setting => 'mode',
      value   => 'slave',
      require => Package[$splunk::package_name],
      notify  => Service[$splunk::virtual_service];
    'splunk_master_uri':
      path    => "${splunk::params::server_confdir}/server.conf",
      section => 'clustering',
      setting => 'master_uri',
      value   => $splunk::master_uri,
      require => Package[$splunk::package_name],
      notify  => Service[$splunk::virtual_service];
    'splunk_pass4SymmKey':
      path    => "${splunk::params::server_confdir}/server.conf",
      section => 'clustering',
      setting => 'pass4SymmKey',
      value   => $splunk::pass4SymmKey,
      require => Package[$splunk::package_name],
      notify  => Service[$splunk::virtual_service];
  }
}
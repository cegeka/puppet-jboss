# Class: jboss
#
# This module manages jboss
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class jboss(
  $version = undef,
  $versionlock = false,
  $service_state = 'running',
  $service_enable = true,
  $java_home = '/usr/java/latest',
  $jboss_mode = 'standalone',
  $jboss_config = 'standalone',
  $jboss_bind_address = '0.0.0.0',
  $jboss_bind_address_mgmt = '0.0.0.0',
  $jboss_min_mem = '256',
  $jboss_max_mem = '512',
  $jboss_perm = '128',
  $jboss_max_perm = '192',
  $jboss_debug = false,
  $jboss_user = 'jboss',
  $jboss_group = 'jboss',
  $jboss_data_dir = '/opt/jboss',
  $jboss_shutdown_wait = '60',
  $jboss_log_dir = undef,
  $jboss_env_props = undef,
  $users_mgmt = []
){

  include stdlib

  anchor { 'jboss::begin': }
  anchor { 'jboss::end': }

  class { 'jboss::package':
    version     => $version,
    versionlock => $versionlock
  }

  class { 'jboss::config':
    version                 => $version,
    java_home               => $java_home,
    jboss_mode              => $jboss_mode,
    jboss_config            => $jboss_config,
    jboss_bind_address      => $jboss_bind_address,
    jboss_bind_address_mgmt => $jboss_bind_address_mgmt,
    jboss_min_mem           => $jboss_min_mem,
    jboss_max_mem           => $jboss_max_mem,
    jboss_perm              => $jboss_perm,
    jboss_max_perm          => $jboss_max_perm,
    jboss_debug             => $jboss_debug,
    jboss_user              => $jboss_user,
    jboss_group             => $jboss_group,
    jboss_data_dir          => $jboss_data_dir,
    jboss_shutdown_wait     => $jboss_shutdown_wait,
    jboss_log_dir           => $jboss_log_dir,
    jboss_env_props         => $jboss_env_props,
    users_mgmt              => $users_mgmt
  }

  class { 'jboss::service':
    ensure  => $service_state,
    version => $version,
    enable  => $service_enable
  }

  Anchor['jboss::begin'] -> Class['Jboss::Package'] -> Class['Jboss::Config'] ~> Class['Jboss::Service'] -> Anchor['jboss::end']

}

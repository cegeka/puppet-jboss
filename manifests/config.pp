class jboss::config(
  $version = undef,
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
  $jboss_log_dir = undef,
  $users_mgmt = []
){

  validate_re($version, '^[~+._0-9a-zA-Z:-]+$')
  validate_re($jboss_mode, '^standalone$|^domain$')
  validate_re($jboss_config, '^standalone$|^standalone-full$|^standalone-ha$|^standalone-full-ha$')
  validate_bool($jboss_debug)

  $jboss_full_version = regsubst($version, '^(\d+\.\d+\.\d+).*','\1')
  $jboss_major_version = regsubst($version, '^(\d+\.\d+).*','\1')
  $package_version = regsubst($jboss_major_version, '\.', '', 'G')

  $jboss_data_dir_real = "${jboss_data_dir}${package_version}"
  $jboss_base_dir_real = "${jboss_data_dir_real}/${jboss_mode}"
  $jboss_config_dir_real = "${jboss_data_dir_real}/${jboss_mode}/configuration"
  $jboss_deployments_dir_real = "${jboss_data_dir_real}/${jboss_mode}/deployments"

  if ($jboss_log_dir != undef) {
    $jboss_log_dir_real = $jboss_log_dir
  } else {
    $jboss_log_dir_real = "${jboss_data_dir_real}/${jboss_mode}/log"
  }

  file { "/etc/sysconfig/jboss${package_version}":
    ensure  => file,
    mode    => '0640',
    content => template("${module_name}/etc/sysconfig/jboss.erb")
  }

  file { $jboss_data_dir_real :
    ensure => directory,
    owner  => $jboss_user,
    group  => $jboss_group
  }

  file { $jboss_base_dir_real :
    ensure  => directory,
    owner   => $jboss_user,
    group   => $jboss_group,
    require => File[$jboss_data_dir_real]
  }

  file { $jboss_config_dir_real :
    ensure  => directory,
    owner   => $jboss_user,
    group   => $jboss_group,
    require => File[$jboss_base_dir_real]
  }

  file { $jboss_deployments_dir_real :
    ensure  => directory,
    owner   => $jboss_user,
    group   => $jboss_group,
    require => File[$jboss_base_dir_real]
  }

  file { $jboss_log_dir :
    ensure  => directory,
    owner   => $jboss_user,
    group   => $jboss_group
  }

  file { "${jboss_base_dir_real}/configuration/mgmt-users.properties":
    ensure  => file,
    mode    => '0644',
    owner   => $jboss_user,
    group   => $jboss_group,
    content => template("${module_name}/conf/mgmt-users.properties.erb"),
    require => File[$jboss_config_dir_real]
  }

  file { "${jboss_base_dir_real}/configuration/mgmt-groups.properties":
    ensure  => file,
    mode    => '0644',
    owner   => $jboss_user,
    group   => $jboss_group,
    replace => false,
    source  => "puppet:///modules/jboss/mgmt-groups.properties",
    require => File[$jboss_config_dir_real]
  }

  file { "${jboss_base_dir_real}/configuration/${jboss_config}.xml":
    ensure  => file,
    mode    => '0644',
    owner   => $jboss_user,
    group   => $jboss_group,
    replace => false,
    source  => "puppet:///modules/jboss/${jboss_config}.xml",
    require => File[$jboss_config_dir_real]
  }

  file { "${jboss_base_dir_real}/configuration/logging.properties":
    ensure  => file,
    mode    => '0644',
    owner   => $jboss_user,
    group   => $jboss_group,
    replace => false,
    source  => "puppet:///modules/jboss/logging.properties",
    require => File[$jboss_config_dir_real]
  }

  file { "${jboss_base_dir_real}/configuration/application-users.properties":
    ensure  => file,
    mode    => '0644',
    owner   => $jboss_user,
    group   => $jboss_group,
    replace => false,
    source  => "puppet:///modules/jboss/application-users.properties",
    require => File[$jboss_config_dir_real]
  }

  file { "${jboss_base_dir_real}/configuration/application-roles.properties":
    ensure  => file,
    mode    => '0644',
    owner   => $jboss_user,
    group   => $jboss_group,
    replace => false,
    source  => "puppet:///modules/jboss/application-roles.properties",
    require => File[$jboss_config_dir_real]
  }

  cron { "cleanup_old_${jboss_mode}_configuration_files":
    ensure  => present,
    command => "find ${jboss_config_dir_real}/${jboss_mode}_xml_history -type f -mtime +14 -delete",
    hour    => 2,
    minute  => 0
  }

  cron { "cleanup_empty_${jboss_mode}_configuration_directories":
    ensure  => present,
    command => "find ${jboss_config_dir_real}/${jboss_mode}_xml_history -type d -empty -delete",
    hour    => 4,
    minute  => 0
  }

}

class jboss::package(
  $version = undef,
  $versionlock = false
){

  validate_re($version, '^[~+._0-9a-zA-Z:-]+$')
  validate_bool($versionlock)

  $jboss_full_version = regsubst($version, '^(\d+\.\d+\.\d+).*','\1')
  $jboss_major_version = regsubst($version, '^(\d+\.\d+).*','\1')
  $package_version = regsubst($jboss_major_version, '\.', '', 'G')

  package { "jboss${package_version}":
    ensure => $version
  }

  package { "cron":
    ensure => present
  }

  case $versionlock {
    true: {
      yum::versionlock { "0:jboss${package_version}-${version}.*": }
    }
    false: {
      yum::versionlock { "0:jboss${package_version}-${version}.*": ensure => absent }
    }
    default: { fail('Class[jboss::Package]: parameter versionlock must be true or false') }
  }

  file { "/etc/init.d/jboss${package_version}":
    ensure  => file,
    mode    => '0755',
    content => template("${module_name}/etc/init.d/jboss.erb")
  }

  Package["jboss${package_version}"] -> File["/etc/init.d/jboss${package_version}"]

}

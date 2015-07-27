class jboss::service(
  $version = undef,
  $ensure = 'running',
  $enable = true
) {

  validate_re($version, '^[~+._0-9a-zA-Z:-]+$')
  validate_re($ensure, '^running$|^stopped$|^unmanaged$')

  $jboss_major_version = regsubst($version, '^(\d+\.\d+).*','\1')
  $package_version = regsubst($jboss_major_version, '\.', '', 'G')

  case $ensure {
    'running', 'stopped': {
      service { "jboss${package_version}":
        ensure     => $ensure,
        enable     => $enable,
        hasstatus  => true,
        hasrestart => true
      }
    }
    'unmanaged': {
      notice('Class[jboss::service]: service is currently not being managed')
    }
    default: {
      fail('Class[jboss::service]: parameter ensure must be running, stopped or unmanaged')
    }
  }

}

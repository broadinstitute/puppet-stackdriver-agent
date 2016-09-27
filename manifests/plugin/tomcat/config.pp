# vim: tabstop=2 expandtab shiftwidth=2 softtabstop=2 foldmethod=marker
#
# == Class: stackdriver::plugin::tomcat::config
#
# Configures Tomcat Monitoring for Stackdriver Agent
#
class stackdriver::plugin::tomcat::config(
) inherits stackdriver::plugin::tomcat {

  # Setup directories
  exec { $::stackdriver::plugin::tomcat::path:
    path    => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => "mkdir -p ${::stackdriver::plugin::tomcat::path}/conf ; mkdir -p ${::stackdriver::plugin::tomcat::path}/log",
    unless  => "test -d ${::stackdriver::plugin::tomcat::path}",
    user    => 'root',
  }

  # Install package
  file { '/mnt/jmxtrans/jmxtrans-all.jar':
    ensure  => $::stackdriver::plugin::tomcat::ensure,
    source  => 'puppet:///modules/stackdriver/tomcat/jmxtrans-all.jar',
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    require => Exec[$::stackdriver::plugin::tomcat::path],
    before  => Service['jmxtrans'],
    notify  => Service['jmxtrans'],
  }

  # Install Conf files
  file { '/mnt/jmxtrans/conf/tomcat-7.json':
    ensure  => $::stackdriver::plugin::tomcat::ensure,
    content => template('stackdriver/tomcat/tomcat-7.json.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    require => Exec[$::stackdriver::plugin::tomcat::path],
    before  => Service['jmxtrans'],
    notify  => Service['jmxtrans'],
  }
  file { '/mnt/jmxtrans/conf/jvm-sun-hotspot.json':
    ensure  => $::stackdriver::plugin::tomcat::ensure,
    content => template('stackdriver/tomcat/jvm-sun-hotspot.json.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    require => Exec[$::stackdriver::plugin::tomcat::path],
    before  => Service['jmxtrans'],
    notify  => Service['jmxtrans'],
  }

  # Install init script
  file { '/etc/init.d/jmxtrans':
    ensure => $::stackdriver::plugin::tomcat::ensure,
    source => 'puppet:///modules/stackdriver/tomcat/initd-jmxtrans',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    before => Service['jmxtrans'],
    notify => Service['jmxtrans'],
  }

  # Overrides via /etc/sysconfig/jmxtrans
  file { '/etc/sysconfig/jmxtrans':
    ensure  => $::stackdriver::plugin::tomcat::ensure,
    content => template('stackdriver/tomcat/sysconfig-jmxtrans.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    before  => Service['jmxtrans'],
    notify  => Service['jmxtrans'],
  }

  service { 'jmxtrans':
    ensure     => $::stackdriver::plugin::tomcat::service_ensure,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => File['/etc/init.d/jmxtrans'],
  }

}

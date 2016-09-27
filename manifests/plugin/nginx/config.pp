# vim: tabstop=2 expandtab shiftwidth=2 softtabstop=2 foldmethod=marker
#
# == Class: stackdriver::plugin::nginx::config
#
# Configures Nginx Agent Plugin for Stackdriver Agent
#
class stackdriver::plugin::nginx::config(
) inherits stackdriver::plugin::nginx {

  file { $::stackdriver::plugin::nginx::config:
    ensure  => file,
    content => template("stackdriver/${::kernel}/${::stackdriver::plugin::nginx::config}.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '0440', # secure
    notify  => Service[$::stackdriver::svc],
  }

}

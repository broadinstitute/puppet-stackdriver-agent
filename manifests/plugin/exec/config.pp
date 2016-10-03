# vim: tabstop=2 expandtab shiftwidth=2 softtabstop=2 foldmethod=marker
#
# == Class: stackdriver::plugin::exec::config
#
# Configures Exec Agent Plugin for Stackdriver Agent
#
class stackdriver::plugin::exec::config(
) inherits stackdriver::plugin::exec {

  file { $::stackdriver::plugin::exec::config:
    ensure  => file,
    content => template("stackdriver/${::kernel}${::stackdriver::plugin::exec::config}.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    notify  => Service[$::stackdriver::svc],
  }

}

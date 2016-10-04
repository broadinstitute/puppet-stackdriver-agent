# puppet-stackdriver-agent
[![Build Status](https://travis-ci.org/broadinstitute/puppet-stackdriver-agent.svg?branch=master)](https://travis-ci.org/broadinstitute/puppet-stackdriver-agent)
[![License (Apache 2.0)](https://img.shields.io/badge/license-Apache-blue.svg)](https://opensource.org/licenses/Apache-2.0)
Installs stackdriver-agent.

This module was forked from https://github.com/dstockman/puppet-stackdriver-agent.  The original module appears to be unsupported currently, so we have created this fork.  We have added rspec tests, merged in several of the outstanding PRs from the original repo, and linked the repo up to [TravisCI](https://travis-ci.org/broadinstitute/puppet-stackdriver-agent) to run the automated tests on PRs.  We have also fixed some bugs we found along the way.

**Note: We have not tested, either manually or in rspec tests, the Windows side of this module.**

## Requirements

- Puppet version 3.4 or greater with Hiera support
- Puppet Forge modules:

| OS Family      | Module |
| :------------- |:-------------: |
| ALL            | [puppetlabs/stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib) |
| Debian         | [puppetlabs/apt](https://forge.puppetlabs.com/puppetlabs/apt) |
| Windows        | [puppetlabs/registry](https://forge.puppetlabs.com/puppetlabs/registry), [joshcooper/powershell](https://forge.puppetlabs.com/joshcooper/powershell) |

Supported/tested Operating Systems by OS Family:

* Debian
    * Ubuntu
* RedHat
    * Amazon
    * CentOS
    * Fedora
* Windows
    * Server 2008
    * Server 2012

## Usage

This module requires a Stackdriver API key.  Stackdriver is now a part of [Google](https://www.google.com), so more information can be found at https://cloud.google.com/monitoring/.

### Base Agent

The stackdriver class includes the client:

```puppet
include stackdriver
```

You must specify your Stackdriver API key:

* Using Hiera (recommended)

```yaml
stackdriver::apikey: 'OMGBECKYLOOKATHERBUTTITSJUSTSOBIG'
```

* Using Puppet Code

```puppet
class { 'stackdriver':
    apikey => 'OMGBECKYLOOKATHERBUTTITSJUSTSOBIG',
}
```

## Plugins

### Usage
---

Two methods are supported for enabling plugins.

#### Using Hiera (recommended)

##### Configuration

Plugin settings may be configured via Hiera using the following format:
```yaml
stackdriver::plugin::<plugin name>::<param>:<value>
```

##### Usage
- Using an External Node Classifier

    Load the `stackdriver::plugin::<plugin name>` class

- Using Hiera

    Plugins may optionally be loaded using hiera itself. NOTE: an array merge is used to collect the plugin list.

    ```yaml
    stackdriver::plugins:
        - 'plugin name'
        - 'plugin name'
    ```

- Using Puppet Code

    Plugins may be enabled via puppet code while keeping the plugin settings in Hiera.

    ```puppet
    stackdriver::plugin { 'plugin name': }
    ```

#### Using Puppet Code

##### Configuration

Plugin settings may be specified during class load.

##### Usage
- Using an External Node Classifier

    Load the `stackdriver::plugin::<plugin name>` class and specify the class parameters.

- Using Puppet Code

    ```puppet
    class { 'stackdriver::plugin::<plugin name>':
        param1 => 'value',
        param2 => 'value',
    }
    ```


### Configuration
---

Plugin defaults are shown using the recommended Hiera format.
Values enclosed in <> do not have defaults and are required.
Values enclosed in () have an undef default and are optional.

### Apache httpd

Configures the Apache httpd plugin on the local host running on port 80.
User and Password settings are only required if the URL requires authentication.

```yaml
stackdriver::plugin::apache::user:     '(OPTIONAL USER)'
stackdriver::plugin::apache::password: '(OPTIONAL USER PASSWORD)'
stackdriver::plugin::apache::url:      'http://127.0.0.1/mod_status?auto'
```

### Elasticsearch

Configures the Elasticsearch plugin on the local host using port 9200.
Host and Port settings are optional.
Prerequisites for this plugin are documented on Stackdriver's [support site](https://cloud.google.com/monitoring/agent/plugins/elasticsearch).

```yaml
stackdriver::plugin::elasticsearch::host: 'localhost'
stackdriver::plugin::elasticsearch::port: '9200'
```

### Exec

Configures the collectd Exec plugin on the local host.  For details
on the format of this line, and limitations of the Exec plugin, see
https://collectd.org/wiki/index.php/Plugin:Exec
All settings are optional.

```yaml
stackdriver::plugin::exec::config: '/opt/stackdriver/collectd/etc/collectd.d/exec.conf'
stackdriver::plugin::exec::execs:
  - Exec "nobody:nobody" "/opt/stackdriver/collectd/bin/autometric" "-v" "-m" "tmp.file.count" "-H" "-c" "/bin/ls /tmp | /usr/bin/wc -l"
```

### Memcached

Configures the memcahed plugin on the local host running on port 11211.
All settings are optional.

```yaml
stackdriver::plugin::memcahed::host: 'localhost'
stackdriver::plugin::memcahed::port: '11211'
```

### MongoDB

Configures the MongoDB plugin on the local host running on port 27017.

```yaml
stackdriver::plugin::mongo::host:     'localhost'
stackdriver::plugin::mongo::user:     'stackdriver'
stackdriver::plugin::mongo::password: 'ahzae8aiLiKoe'
stackdriver::plugin::mongo::port:     '27017'
```

### Nginx

Configures the Nginx plugin on the local host running on port 80 (with authentication).

```yaml
stackdriver::plugin::nginx::url:      'http://127.0.0.1/nginx_status'
stackdriver::plugin::nginx::user:     'stackdriver'
stackdriver::plugin::nginx::password: 'Eef3haeziqu3j'
```

Configures the Nginx plugin on the local host running on port 443 (SSL, no authentication, no verification).

```yaml
stackdriver::plugin::nginx::url:        'https://127.0.0.1/nginx_status'
stackdriver::plugin::nginx::verifypeer: false
stackdriver::plugin::nginx::verifyhost: false
```

### Postgresql

Configures the Postgreqsql plugin on the local host using UNIX domain sockets.
Prerequisites for this plugin are documented on Stackdriver's [support site](https://cloud.google.com/monitoring/agent/plugins/postgreSQL).

```yaml
stackdriver::plugin::postgres::user:     'stackdriver'
stackdriver::plugin::postgres::password: 'xoiboov9Pai5e'
stackdriver::plugin::postgres::dbname:   '<REQUIRED PARAM>'
```

### RabbitMQ

Configures the RabbitMQ plugin on the local host running on port 15672.
The defaults for all settings are listed below.  The queue names must
be unique and defaults to a null string ('') if not specified.

```yaml
stackdriver::plugin::rabbitmq::queues:
  - vhost: '/'
    host:     'localhost'
    port:     '15672'
    name:     '(First Queue Name)'
    user:     'guest'
    password: 'guest'
  - vhost: '/'
    host:     'localhost'
    port:     '15672'
    name:     '(Second Queue Name)'
    user:     'guest'
    password: 'guest'
```

### Redis

Configures the redis plugin on the local host running on port 6379.
**Note: this module requires hiredis-devel be available to the system.**

```yaml
stackdriver::plugin::redis::host:    'localhost'
stackdriver::plugin::redis::port:    '6379'
stackdriver::plugin::redis::timeout: '2000'
```

### Tomcat

Configures monitoring for Tomcat on the local host running JMX on port 9991.
For reference on Stackdriver's [support site](https://cloud.google.com/monitoring/agent/plugins/tomcat).

You can use the sysconfig parameter to create the `/etc/sysconfig/jmxtrans` override config.

```yaml
stackdriver::plugin::tomcat::ensure: 'present'
stackdriver::plugin::tomcat::host:   'localhost'
stackdriver::plugin::tomcat::port:   '9991'
stackdriver::plugin::tomcat::path:   '/mnt/jmxtrans'
stackdriver::plugin::tomcat::sysconfig:
    'JAVA_HOME': '/usr/java/jdk1.7.0_45/'
```

Pre-requisite: Enabling JMX remote on Tomcat is outside the scope of this module.
Below are the changes you need to apply to your Tomcat.

```bash
# Enable JMX Monitoring on Tomcat (/etc/sysconfig/tomcat)
JAVA_OPTS="${JAVA_OPTS} -Dcom.sun.management.jmxremote"
JAVA_OPTS="${JAVA_OPTS} -Dcom.sun.management.jmxremote.port=9991"
JAVA_OPTS="${JAVA_OPTS} -Dcom.sun.management.jmxremote.authenticate=false"
JAVA_OPTS="${JAVA_OPTS} -Dcom.sun.management.jmxremote.ssl=false"
JAVA_OPTS="${JAVA_OPTS} -Djava.rmi.server.hostname=<%= @fqdn %>"
```

### Zookeeper

Configures the zookeeper plugin on the local host running on port 2181.

```yaml
stackdriver::plugin::zookeeper::host:    'localhost'
stackdriver::plugin::zookeeper::port:    '2181'
```

## See Also

* Stackdriver Website: [https://cloud.google.com/monitoring/](https://cloud.google.com/monitoring/)

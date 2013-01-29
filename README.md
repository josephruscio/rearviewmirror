# rearviewmirror

rearviewmirror is a simple script for gathering Nagios problem statistics and submitting them to Librato. It focuses on summary (overall, servicegroup and hostgroup) statistics and writes them to the `nagios.problems` metrics namespace within Librato.

rearviewmirror is a fork of [Ledbetter](https://github.com/github/ledbetter).

## Installation

Clone the GitHub repository and use Bundler to install the gem dependencies.

```
$ git clone https://github.com/github/rearviewmirror.git
$ cd rearviewmirror
$ bundle install
```

## Usage

rearviewmirror requires a number of environment variables for runtime configuration. The following example demonstrates how to run it manually from the command line, but you would typically run it as a cron job.

```
$ export NAGIOS_URL=http://nagios.foo.com/cgi-bin/nagios3
$ export NAGIOS_USER=foo
$ export NAGIOS_PASS=bar
$ export LIBRATO_USER="foo@bar.com"
$ export LIBRATO_TOKEN="aec123765489fe45a6"
$ bundle exec ruby rearviewmirror.rb
```

Optionally you can set `VERBOSE=1` to also print statistics to `stdout`. `LIBRATO_PREFIX` can also be set to override the default namespace (`nagios.problems`).

```
$ VERBOSE=1 bundle exec ruby rearviewmirror.rb
nagios.problems.all 41 1359170720
nagios.problems.critical 27 1359170720
nagios.problems.warning 12 1359170720
nagios.problems.unknown 2 1359170720
nagios.problems.servicegroups.apache 0 1359170720
nagios.problems.servicegroups.backups 3 1359170720
nagios.problems.servicegroups.dns 0 1359170720
nagios.problems.servicegroups.mysql 1 1359170720
...
```

## License 

rearviewmirror is distributed under the MIT license.

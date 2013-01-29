require 'nagiosharder'
require 'librato/metrics'

# Ensure we have all the nagios configuration
nagios_user = ENV['NAGIOS_USER'] || raise('missing NAGIOS_USER')
nagios_pass = ENV['NAGIOS_PASS'] || raise('missing NAGIOS_PASS')
nagios_url  = ENV['NAGIOS_URL'] || raise('missing NAGIOS_URL')

# Ensure we have all the librato configuration
librato_user  = ENV['LIBRATO_USER'] || raise('missing LIBRATO_USER')
librato_token = ENV['LIBRATO_TOKEN'] || raise('missing LIBRATO_TOKEN')

# Authenticate to Librato
begin
  Librato::Metrics.authenticate librato_user, librato_token
rescue
  raise "Unable to connect to Librato"
end

# connect to Nagios server
begin
  site = NagiosHarder::Site.new(nagios_url, nagios_user, nagios_pass)
rescue
  raise "unable to connect to NAGIOS_URL at #{nagios_url}"
end

# Create a queue so we only perform a single POST to Librato
$queue = Librato::Metrics::Queue.new

# XXX: Hack using globals to DRY out the code.
# If this works and we make a proper gem, we can clean
# this up.
#
# see if we have a custom metrics prefix
$librato_prefix = ENV['LIBRATO_PREFIX'] || 'nagios.problems'

# grab current timestamp
$time = Time.now.to_i

def librato_enqueue(k, v)
  metric = "#{$librato_prefix}.#{k}"

  $queue.add metric => { :measure_time => $time, :value => v}

  if ENV['VERBOSE'].to_i.eql?(1)
    puts "#{metric} #{v} #{$time}"
  end
end

# fetch our service problem counts by type
critical = site.service_status(:service_status_types => ['critical']).count
warning = site.service_status(:service_status_types => ['warning']).count
unknown = site.service_status(:service_status_types => ['unknown']).count
all = critical + warning + unknown

librato_enqueue 'all', all
librato_enqueue 'critical', critical
librato_enqueue 'warning', warning
librato_enqueue 'unknown', unknown

# fetch our service problem counts by group
site.servicegroups_summary.each do |name, group|
  service_problems = group['service_status_counts']['critical'].to_i +
                     group['service_status_counts']['warning'].to_i +
                     group['service_status_counts']['unknown'].to_i

  librato_enqueue "servicegroups.#{group['group']}", service_problems
end

# fetch our host problem counts by group
site.hostgroups_summary.each do |name, group|
  down = group['host_status_counts']['down']
  librato_enqueue "hostgroups.#{group['group']}", down
end

# Flush the queue to Librato
queue.submit

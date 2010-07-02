# Class: lmsensors
#
# This module manages lmsensors - http://www.lm-sensors.org/
#
# Requires:
#   class puppet
#
class lmsensors {

    include puppet

    # only do stuff if this is a real machine and not virtualized
    # note: under qemu virtual => physical and lm_sensors has no effect
    # though it is installed. At Linode.com virtual => xenu and does
    # not work and should not be installed
    case $virtual {
        physical: {
            case $productname {
                # systems that do not use KVM have productname blank
                default: {
                    package { "lm_sensors":
                        notify => Exec["/usr/sbin/sensors-detect"],
                    } # package

                    exec { "/usr/sbin/sensors-detect":
                        command     => "/usr/bin/yes YES | /usr/sbin/sensors-detect > ${puppet::semaphores}/$name",
                        require     => Package["lm_sensors"],
                        notify      => Service["lm_sensors"],
                        creates     => "${puppet::semaphores}/$name",
                        refreshonly => true,
                    } # exec

                    service { "lm_sensors":
                        enable  => true,
                        require => Package["lm_sensors"],
                    } # service
                } # default

                # do nothing if its virtual
                kvm: { }

            } # case $productname
        } # physical

        # by default do nothing
        default: { }
   } # case $virtual
} # class lmsensors

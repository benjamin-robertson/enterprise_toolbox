#!/opt/puppetlabs/puppet/bin/ruby

# facts defs

REGEX_FACTS = [%r{^blockdevice_(?<devicename>.*)_(?<attribute>model|size|vendor)$},
    %r{^(?<attribute>ipaddress|ipaddress6|macaddress|mtu|netmask|netmask6|network|network6)_(?<interface>.*)$},
    %r{^processor(?<id>[0-9]+)$},
    %r{^sp_(?<name>.*)$},
    %r{^ssh(?<algorithm>dsa|ecdsa|ed25519|rsa)key$},
    %r{^ldom_(?<name>.*)$},
    %r{^zone_(?<name>.*)_(?<attribute>brand|iptype|name|uuid|id|path|status)$}].freeze

LEGACY_FACTS = [
    'memoryfree_mb', 'memorysize_mb', 'swapfree_mb',
    'swapsize_mb', 'blockdevices', 'interfaces', 'zones',
    'sshfp_dsa', 'sshfp_ecdsa', 'sshfp_ed25519', 'sshfp_rsa',
    'architecture', 'augeasversion', 'bios_release_date', 'bios_vendor',
    'bios_version', 'boardassettag', 'boardmanufacturer', 'boardproductname',
    'boardserialnumber', 'chassisassettag', 'chassistype', 'domain',
    'fqdn', 'gid', 'hardwareisa', 'hardwaremodel',
    'hostname', 'id', 'ipaddress', 'ipaddress6',
    'lsbdistcodename', 'lsbdistdescription', 'lsbdistid', 'lsbdistrelease',
    'lsbmajdistrelease', 'lsbminordistrelease', 'lsbrelease', 'macaddress',
    'macosx_buildversion', 'macosx_productname', 'macosx_productversion', 'macosx_productversion_major',
    'macosx_productversion_minor', 'manufacturer', 'memoryfree', 'memorysize',
    'netmask', 'netmask6', 'network', 'network6',
    'operatingsystem', 'operatingsystemmajrelease', 'operatingsystemrelease', 'osfamily',
    'physicalprocessorcount', 'processorcount', 'productname', 'rubyplatform',
    'rubysitedir', 'rubyversion', 'selinux', 'selinux_config_mode',
    'selinux_config_policy', 'selinux_current_mode', 'selinux_enforced', 'selinux_policyversion',
    'serialnumber', 'swapencrypted', 'swapfree', 'swapsize',
    'system32', 'uptime', 'uptime_days', 'uptime_hours',
    'uptime_seconds', 'uuid', 'xendomains', 'zonename'
    ].freeze

# Params here
environment='development'
pattern=[/\.pp$/,/\.epp$/,/\.erb$/,/\.yaml$/]

pattern.push(/\.rb/)

def get_pp_files(files, folder, pattern)
    Dir.glob(folder) do | file |
        if File.directory?(file)
            get_pp_files(files, "#{file}/*", pattern)
        else
            pattern.each do | i | 
                file.match?(i) ? files.push(file) : next
            end
        end
    end
end

files = []
get_pp_files(files, "/etc/puppetlabs/code/environments/#{environment}/*", pattern)

# puts files

def check_file(file)
    handle    = File.open(file, 'r')
    count     = 0
    handle.each_line do | line |
        count = count + 1
        # Check if line is commented
        next if line.match?(/^#/)
        # check for easy facts.
        LEGACY_FACTS.each do | easy |
            if file.match?(/\.pp$|\.epp$|\.erb$/)
                # check epp pp and erb
                if line.match?(/[\$\@]facts\[\'#{easy}\'\]/)
                    puts "File: #{file} contains legacy fact #{easy} on line #{count}"
                elsif line.match?(/[\$\@]#{easy}[ %={]/)
                    puts "File: #{file} contains legacy fact #{easy} on line #{count}"
                elsif line.match?(/[\$\@]\:\:#{easy}[ %={]/)
                    puts "File: #{file} contains legacy fact #{easy} on line #{count}"
                end
            elsif file.match?(/\.rb$/)
                # check rb only
                if line.match?(/Factor.value\(\'#{easy}\'\)/)
                    puts "File: #{file} contains legacy fact #{easy} on line #{count}"
                elsif line.match?(/confine #{easy}\:/)
                    puts "File: #{file} contains legacy fact #{easy} on line #{count}"
                end
            elsif file.match?(/\.yaml$/)
                if line.match?(/\%\{\:\:#{easy}\}/)
                    puts "File: #{file} contains legacy fact #{easy} on line #{count}"
                elsif line.match?(/\%\{#{easy}\}/)
                    puts "File: #{file} contains legacy fact #{easy} on line #{count}"
                elsif line.match?(/\%\{facts.#{easy}\}/)
                    puts "File: #{file} contains legacy fact #{easy} on line #{count}"
                end
            end
        end
        REGEX_FACTS.each do | regex |
            if line.match?(regex)
                puts "File: #{file} contains legacy fact #{regex} on line #{count}"
            end
        end
    end
end

files.each do | file |
    check_file(file)
end


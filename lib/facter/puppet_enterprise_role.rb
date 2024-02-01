# frozen_string_literal: true
require 'open3'
require 'json'
require 'socket'

Facter.add(:puppet_enterprise_role) do
  confine kernel: 'windows'
  setcode do
    # confirm this is a pe
    if Facter.value(:pe_version).to_s.empty? then
      return nil
    end

    def get_puppet_role
      output, status = Open3.capture2('puppet infrastructure status')
      hostname = Socket.gethostname
      results = {}

      # Populate the hash with value for Primary and Replica
      output.each_line do |line|
        if line.match(/^Primary: /)
          results['Primary'] = line.gsub(/^Primary: /, '').lstrip.rstrip
        elsif line.match(/^Master: /)
          results['Primary'] = line.gsub(/^Master: /, '').lstrip.rstrip
        elsif line.match(/^Replica: /)
          results['Replica'] = line.gsub(/^Replica: /, '').lstrip.rstrip
        end
      end

      # Compare our hostname to results
      results.each do |k,v|
        if v.include? hostname
          return k
        end
      end

      # If we have not matched, we are probably running on a compiler.
      if status != 0
        return "Compiler"
      end
    end

    get_puppet_role()

  end
end

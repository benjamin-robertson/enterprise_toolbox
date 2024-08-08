#!/opt/puppetlabs/puppet/bin/ruby

def get_pp_files(files, folder)
    Dir.glob(folder) do | file |
        if File.directory?(file)
            get_pp_files(files, "#{file}/*")
        elsif file.match
            files.push(file)
        end
    end
end

files = []
get_pp_files(files, '/etc/puppetlabs/code/environments/development/*')
# get_pp_files(files, '/opt/puppetlabs/puppet/include/*')

puts files.length

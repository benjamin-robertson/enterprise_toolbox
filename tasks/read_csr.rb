#!/opt/puppetlabs/puppet/bin/ruby

require 'openssl'
require 'json'

def get_extensions(certificate)
  # set all known trusted facts
  trusted_facts_oid = { 'pp_uuid' => '1.3.6.1.4.1.34380.1.1.1', 'pp_instance_id' => '1.3.6.1.4.1.34380.1.1.2', 'pp_image_name' => '1.3.6.1.4.1.34380.1.1.3', 'pp_preshared_key' => '1.3.6.1.4.1.34380.1.1.4', 'pp_cost_center' => '1.3.6.1.4.1.34380.1.1.5', 'pp_product' => '1.3.6.1.4.1.34380.1.1.6', 'pp_project' => '1.3.6.1.4.1.34380.1.1.7', 'pp_application' => '1.3.6.1.4.1.34380.1.1.8', 'pp_service' => '1.3.6.1.4.1.34380.1.1.9', 'pp_employee' => '1.3.6.1.4.1.34380.1.1.10', 'pp_created_by' => '1.3.6.1.4.1.34380.1.1.11', 'pp_environment' => '1.3.6.1.4.1.34380.1.1.12', 'pp_role' => '1.3.6.1.4.1.34380.1.1.13', 'pp_software_version' => '1.3.6.1.4.1.34380.1.1.14', 'pp_department' => '1.3.6.1.4.1.34380.1.1.15', 'pp_cluster' => '1.3.6.1.4.1.34380.1.1.16', 'pp_provisioner' => '1.3.6.1.4.1.34380.1.1.17', 'pp_region' => '1.3.6.1.4.1.34380.1.1.18', 'pp_datacenter' => '1.3.6.1.4.1.34380.1.1.19', 'pp_zone' => '1.3.6.1.4.1.34380.1.1.20', 'pp_network' => '1.3.6.1.4.1.34380.1.1.21', 'pp_securitypolicy' => '1.3.6.1.4.1.34380.1.1.22', 'pp_cloudplatform' => '1.3.6.1.4.1.34380.1.1.23', 'pp_apptier' => '1.3.6.1.4.1.34380.1.1.24', 'pp_hostname' => '1.3.6.1.4.1.34380.1.1.25' }

  begin
    csr = OpenSSL::X509::Request.new certificate
  rescue
    return false
  end

  attribute = csr.attributes.find { |a| a.oid == 'extReq' }
  sequence = attribute.value
  trusted_facts = {}

  sequence.value.each do |element|
    element.value.length.times do |num|
      value = OpenSSL::ASN1.decode(element.value[num]).value
      trusted_facts[trusted_facts_oid.key(value[0].value.strip)] = value[1].value.strip.gsub(%r{[^a-zA-Z\d\/\:_-]}, '')
    end
  end
  trusted_facts
end

# Read paramerters from STDIN
params = JSON.parse(STDIN.read)
csr_path = params['csr_path']
csr_files = Dir.entries(csr_path)
certname_to_return = params['node_name']

csr_files.each do |file|
  unless file.include?('.pem') then next end
  certificate = File.read("#{csr_path}/#{file}")
  trusted_facts = get_extensions(certificate)
  unless trusted_facts then next end

  if certname_to_return.length >= 2
    unless file.include?(certname_to_return) then next end
  end
  # Print out request details
  puts "Certname: #{file}"
  puts '------------------------------------------------------------------------'
  trusted_facts.each do |k, v|
    puts "#{k}: #{v}"
  end
  puts
end

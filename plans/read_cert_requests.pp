# @summary PE plan to read the trusted extensions on unsigned certificates.
#
# lint:ignore:140chars lint:ignore:strict_indent
#
# @param csr_path Specify Puppet Server ca path, default for Puppet 7.0 and later.
# @param node_name Specify a single node to return results for. 
plan enterprise_toolbox::read_cert_requests (
  Enum['/etc/puppetlabs/puppetserver/ca/requests','/etc/puppetlabs/puppet/ssl/ca/requests'] $csr_path  = '/etc/puppetlabs/puppetserver/ca/requests',
  Optional[String]                                                                          $node_name = undef,
) {
  # We need to get the primary server. Check pe_status_check fact. otherwise fall back to built in fact.
  $pe_status_results = puppetdb_query('inventory[certname] { facts.pe_status_check_role = "primary" }')
  if $pe_status_results.length != 1 {
    # check with built-in puppet_enterprise_role fact
    $pe_role_results = puppetdb_query('inventory[certname] { facts.puppet_enterprise_role = "Primary" }')
    if $pe_role_results.length != 1 {
      fail("Could not identify the primary server. Confirm the puppet_enterprise_role fact or pe_status_check_role fact is working correctly. Results: ${pe_role_results}")
    } else {
      $pe_target = $pe_role_results
    }
  } else {
    # We found a single primary server :)
    $pe_target = $pe_status_results
  }
  $pe_target_certname = $pe_target.map | Hash $node | { $node['certname'] }
  out::message("pe_target_certname is ${pe_target_certname}")

  $task_results = run_task('enterprise_toolbox::read_csr', $pe_target_certname, { 'csr_path' => $csr_path, 'node_name' => $node_name, '_catch_errors' => true })

  # out::message("${$task_results[0].message}")

  $results = $task_results[0].message
  return($results)
}
#lint:endignore

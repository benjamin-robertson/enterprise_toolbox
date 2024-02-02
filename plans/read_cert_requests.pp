# @summary PE plan to update trusted facts on a certificate via Puppet enterprise console, while preserving existing trusted facts.
#
# lint:ignore:140chars lint:ignore:strict_indent
# 
# This plans allows for the easy modification of trusted facts on already deployed nodes via the Puppet Enterprise console.
# It will preserve the existing trusted facts by reading the existing certificate and merging any proposed changes over existing. This behaviour can be changed by setting the preserve_existing_facts parameter to false
# We require the Puppet Primary to be specified when runing the plan due to limitations of running plans in orchestor. 
#
# To learn more about Puppet plans, see documentation:
# - http://pup.pt/bolt-puppet-plans
# - https://www.puppet.com/docs/pe/2021.7/plans_limitations.html
#
# @param node_name Specify a single node to return results for. 
plan enterprise_toolbox::read_cert_requests (
  Optional[String] $node_name = undef,
) {
  # We need to get the primary server. Check pe_status_check fact. otherwise fall back to built in fact.
  $pe_status_results = puppetdb_query('inventory[certname] { facts.pe_status_check_role = "primary" }')
  if $pe_status_results.length != 1 {
    # check with built-in puppet_enterprise_role fact
    $pe_role_results = puppetdb_query('inventory[certname] { facts.puppet_enterprise_role = "Primary" }')
    if $pe_role_results != 1 {
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

  $task_results = run_task('enterprise_toolbox::read_csr', $pe_target_certname, { '_catch_errors' => true })

  out::message("${$task_results} results")
}
#lint:endignore

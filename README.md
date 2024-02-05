# enterprise_toolbox

Enterprise toolbox contains useful tools for working with Puppet Enterprise. These tools fill in the gaps where Puppet Enterprise does not natively provide easy solutions. 

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with enterprise_toolbox](#setup)
    * [What enterprise_toolbox affects](#what-enterprise_toolbox-affects)
    * [Beginning with enterprise_toolbox](#beginning-with-enterprise_toolbox)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

Presently, enterprise_toolbox contains a Puppet plan to read certificate extensions on unsigned certificates.

Currently I have a few discrete modules containing a single purpose tool tool. The plan is consolidate these into this single module. 

* https://forge.puppet.com/modules/benjaminrobertson/update_trusted_facts
* https://forge.puppet.com/modules/benjaminrobertson/migrate_nodes/readme

## Setup

### What enterprise_toolbox affects

Enterprise_toolbox presently does not make any configuration changes. 

The fact `puppet_enterprise_role` is install to determine which host is the primary server if the `pe_status_check_role` fact is not available. 

### Beginning with enterprise_toolbox

Include module in your Puppetfile.

`mod 'benjaminrobertson-enterprise_toolbox'`

## Usage

Run the plan **enterprise_toolbox::read_cert_requests** from the Puppet Enterprise console.

**Optional parameters**
- csr_path (String) - Path to certificate request directory. Defaults to Puppet 7.0 > directory [For more info](https://www.puppet.com/docs/pe/2021.7/osp/server/release_notes#puppet-server-700)
- node_name (Sting) - Filter by node name. Can do a partial match. Can match multiple nodes. 

## Limitations

* Developed on Puppet Enterprise 2021.7.6
* Expected to work with all modern versions of Puppet.

## Development

If you find any issues with this module, please log them in the issues register of the GitHub project. [Issues][1]

PR glady accepted :)

[1]: https://github.com/benjamin-robertson/enterprise_toolbox/issues

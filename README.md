OFMCanberra Example Cookbook
====================
An example cookbook of how to install BPM 12.2.1 on Java Cloud Service instance on the Oracle Cloud Cloud Platform. This is primarily built from cookbooks from the [oralce chef-samples](https://github.com/oracle/chef-samples), but tailored (and simplified) to support the Oracle Cloud. This is only an example, so you may want to take this inspiration and use it's concepts in your cookbook, rather than rely on this 'beta' code. 

Requirements
------------
This will only run a 12.2.1 instance on the JCS. It expects certain folders and scripts to exist. It also FTPs the binaries from a central FTP server, so you will need to set one up in your cloud (or point it somewhere else) and modify the hard-coded FTP address. 

Attributes
----------
The following attributes need to be set. If you run this via the (knife-oraclepaas)[https://github.com/Joelith/knife-oraclepaas] plugin in a `java create` or `stack build` command these will be automatically filled in. See below for example on how to run this
#### ofmcanberra_example::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['oracle']['service_name']</tt></td>
    <td>String</td>
    <td>The service name of the instance</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>['oracle']['db_service_name']</tt></td>
    <td>String</td>
    <td>The service name of the database instance this JCS connects to (used by the RCU script to add the schemas to support SOA/BPM)</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>['oracle']['dba_name']</tt></td>
    <td>String</td>
    <td>The name of the db user to connect RCU as (usually SYS)</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>['oracle']['dba_password']</tt></td>
    <td>String</td>
    <td>The password of the db user to connect RCU. Note: At the moment this is sent in plain-text and not encrypted</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>['oracle']['identity_domain']</tt></td>
    <td>String</td>
    <td>Your identity domain. This is used to build URLs in the server correctly</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>['oracle']['weblogic_password']</tt></td>
    <td>String</td>
    <td>The password of the weblogic password. Note: At the moment this is sent in plain-text and not encrypted. Plus it assumes there is a weblogic user</td>
    <td></td>
  </tr>
</table>

Usage
-----
#### ofmcanberra_example::default
Just include `ofmcanberra_example` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[ofmcanberra_example]"
  ]
}
```

License and Authors
-------------------
Authors: Joel Nation
Copyright: Oracle Corporation, 2016

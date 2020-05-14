## SWEAGLE INTEGRATION TO PUPPET PREREQUITES

# HOW TO INSTALL PUPPET

Instructions below details how to install puppet in order to test integration with SWEAGLE

1- Install Puppet Open Source version using docker-compose package and instructions here:
https://puppet.com/try-puppet/open-source-puppet/download/

2- Then install puppet agent
- for linux, instructions are here:
https://puppet.com/docs/puppet/latest/install_agents.html#task-4349

example for Red Hat EL7:
`sudo rpm -Uvh https://yum.puppet.com/puppet6-release-el-7.noarch.rpm`
`sudo yum install puppet-agent`

2.1- configure the agent
`vi /etc/hosts`
=> Add a line to configure your puppet server IP and put 'puppet' as hostname
`<IP>  puppet`
ATTENTION, IT IS REQUIRED TO PUT 'PUPPET' AS HOSTNAME FOR CERTIFICATE GENERATION TO WORK

vi /etc/puppetlabs/puppet/puppet.conf
Add
server = puppet

2.2 Test and generate certificate request
puppet agent --server puppet --waitforcert 60 --test
puppet agent -t

2.2- Start puppet agent service
sudo /opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true
systemctl status puppet


# CHECK
Do a `docker ps`to identify which local port is using your puppet server container
(identify the port map to 8080)

then `http://localhost:<port>` to see if puppet is working and node is connected

Connect to your agent node and launch `facter --json` to get puppet facts in json format


# YOUR FIRST DEPLOYMENT

- create a site.pp with content below
file {'/tmp/example-ip':                                            # resource type file and filename
  ensure  => present,                                               # make sure it exists
  mode    => "0644",                                                # file permissions
  content => "Here is my hostname: ${hostname}.\n"
}

- Copy site.pp into your puppet server container
`sudo docker cp ./site.pp pupperware_puppet_1:/etc/puppetlabs/code/environments/production/manifests`

- From your puppet node, start deployment and check result
`puppet agent --test`
`cat /tmp/example-ip`

Troubleshoot:
- Enter the puppet master container and create target directory if not present
`sudo docker exec -it pupperware_puppet_1 /bin/bash`

# OTHER RESOURCES

- for more details https://www.digitalocean.com/community/tutorials/how-to-install-puppet-to-manage-your-server-infrastructure
- or more complex https://www.digitalocean.com/community/tutorials/getting-started-with-puppet-code-manifests-and-modules

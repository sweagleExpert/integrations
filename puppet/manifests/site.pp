
# Install SWEAGLE CLI on the target system
node "default" {
        include sweagle_install_cli
}

exec { 'create_facts_file':
  path    => ['/opt/puppetlabs/bin', '/usr/bin', '/usr/sbin', '/bin'],
  command => "facter --json > /tmp/facts.json"
}

exec { 'import_facts_to_sweagle':
  cwd     => '/opt/sweagle/cli',
  path    => ['/opt/sweagle/cli', '/usr/bin', '/usr/sbin', '/bin'],
  command => 'sweagle uploadData --filePath /tmp/facts.json --nodePath puppet_facts,$(hostname) --type json --autoRecognize --autoApprove',
  #consume => sweagle[cli]
}

exec { 'sweagle_validate':
  cwd       => '/opt/sweagle/cli',
  path      => ['/opt/sweagle/cli', '/usr/bin', '/usr/sbin', '/bin'],
  command   => 'sweagle validate hiera --validator passwordChecker-puppet',
  logoutput => true
  #consume => sweagle[cli]
}

exec { 'Fail if SWEAGLE validate fails':
  cwd       => '/opt/sweagle/cli',
  path      => ['/opt/sweagle/cli', '/usr/bin', '/usr/sbin', '/bin'],
  command   => 'sweagle validate hiera --validator passwordChecker-puppet | grep -c "passed: true"',
  #consume => sweagle[cli]
}

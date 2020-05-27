class sweagle_install_cli {

user { 'sweagle':
        ensure => present,
        name => 'sweagle',
        groups => 'sweagle'
    }

if $::osfamily == 'linux' {
  # Install for linux OS
  file { '/opt/sweagle/cli':
          ensure => directory,
          owner => 'sweagle',
          group => 'sweagle'
      }
  file { '/usr/bin/sweagle':
          mode => '0755',
          owner => 'sweagle',
          group => 'sweagle',
          source => 'puppet:///modules/sweagle_install_cli/sweagle-linux',
      }
  file { '/opt/sweagle/cli/db.json':
          mode => '0644',
          owner => 'sweagle',
          group => 'sweagle',
          source => 'puppet:///modules/sweagle_install_cli/db.json'
      }

} elsif $::osfamily == 'darwin' {
  # Install for MacOS
  file { '/opt/sweagle/cli':
          ensure => directory,
          owner => 'sweagle',
          group => 'sweagle'
      }
  file { '/usr/local/bin/sweagle':
          mode => '0755',
          owner => 'sweagle',
          group => 'sweagle',
          source => 'puppet:///modules/sweagle_install_cli/sweagle-macos',
      }
  file { '/opt/sweagle/cli/db.json':
          mode => '0644',
          owner => 'sweagle',
          group => 'sweagle',
          source => 'puppet:///modules/sweagle_install_cli/db.json'
      }

} elsif $::osfamily == 'windows' {
  # Install for WindowsOS
  file { 'C:\windows\program files\sweagle':
          ensure => directory,
          owner => 'sweagle',
          group => 'sweagle'
      }
  file { 'C:\windows\system\sweagle.exe':
          mode => '0755',
          owner => 'sweagle',
          group => 'sweagle',
          source => 'puppet:///modules/sweagle_install_cli/sweagle-win.exe',
      }
  file { 'C:\windows\program files\sweagle\db.json':
          mode => '0644',
          owner => 'sweagle',
          group => 'sweagle',
          source => 'puppet:///modules/sweagle_install_cli/db.json'
      }
}

}

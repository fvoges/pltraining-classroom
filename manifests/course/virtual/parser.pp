class classroom::course::virtual::parser (
  $session_id         = $classroom::params::session_id,
  $role               = $classroom::params::role,
  $offline            = $classroom::params::offline,
  $jvm_tuning_profile = $classroom::params::jvm_tuning_profile,
) inherits classroom::params {
  class { 'classroom::virtual':
    offline            => $offline,
    jvm_tuning_profile => $jvm_tuning_profile,
  }

  if $role == 'master' {

    class { 'puppetfactory':
      plugins          => [ "Certificates", "Classification", "ConsoleUser", "Docker", "Logs", "ShellUser", "UserEnvironment" ],
      puppetcode       => '/var/puppetcode',
      stagedir         => '/etc/puppetlabs/code',
      modulepath       => 'readwrite',
      usersuffix       => $classroom::params::usersuffix,
      session          => $session_id,
      privileged       => false,
    }
  }
  else {
    file { '/usr/local/bin/course_selector':
      ensure => present,
      mode   => '0755',
      source => '/usr/src/courseware-lms-content/scripts/course_selector.rb',
      require => Vcsrepo['/usr/src/courseware-lms-content'],
    }
    # Clone the courseware and copy example files to appropriate places
    vcsrepo { '/usr/src/courseware-lms-content':
      ensure   => present,
      provider => git,
      source   => 'https://github.com/puppetlabs/courseware-lms-content.git',
    }
  }

}

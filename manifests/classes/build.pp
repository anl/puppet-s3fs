class s3fs::build {

  # s3fs version >1.19 requires fuse > 2.8.4:
  if ($lsbdistdescription == 'Ubuntu 10.10') {
    $version = '1.35'
  } else {
    $version = "1.19"
  }

  # Build/run requirements:
  case $operatingsystem {
    
    CentOS: { $prereqs = [ "curl-devel", "fuse", "fuse-libs", "fuse-devel",
                           "libxml2-devel", "mailcap", ] }
                         
    Ubuntu: { $prereqs = [ "g++", "libcurl4-openssl-dev", "libxml2-dev",
                           "libfuse-dev", ] }
                         
  }
  package { $prereqs: ensure => installed }

  # Distribute s3fs source from within module to control version (could
  # also download from Google directly):
  file { "/root/s3fs-$version.tar.gz":
    owner => root,
    group => root,
    mode => 644,
    source => "puppet:///s3fs/s3fs-$version.tar.gz",
  }
  
  # Extract s3fs source:
  exec { "extract s3fs":
    creates => "/root/s3fs-$version",
    cwd => "/root",
    command => "/bin/tar --no-same-owner -xzf /root/s3fs-$version.tar.gz",
    logoutput => true,
    timeout => 300,
    require => File["/root/s3fs-$version.tar.gz"],
  }

  # Configure s3fs build:
  exec { "configure s3fs build":
    creates => "/root/s3fs-$version/config.status",
    cwd => "/root/s3fs-$version",
    command => "/root/s3fs-$version/configure --program-suffix=-$version",
    logoutput => true,
    timeout => 300,
    require => [ Package[$prereqs], Exec["extract s3fs"], ]
  }

  # Build s3fs:
  exec { "make s3fs":
    creates => "/root/s3fs-$version/src/s3fs",
    cwd => "/root/s3fs-$version",
    command => "/usr/bin/make",
    logoutput => true,
    timeout => 300,
    require => Exec["configure s3fs build"],
  }
  
  # Install s3fs
  exec { "install s3fs":
    creates => "/usr/local/bin/s3fs-$version",
    cwd => "/root/s3fs-$version",
    command => "/usr/bin/make install",
    logoutput => true,
    timeout => 300,
    require => Exec["make s3fs"],
  }
  
}

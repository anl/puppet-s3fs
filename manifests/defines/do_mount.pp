# Complete mounting of an S3 bucket on to the local file system.

# $title: S3 bucket to be mounted
# $aws_acct: set of credentials for an S3 bucket
# /$root/$aws_acct/$leaf: Path to mounted bucket, for crude permissioning

define s3fs::do_mount($aws_acct, $root, $leaf) {

  $mountpoint = "${root}/${aws_acct}/${leaf}"
  
  # Create mountpoint:
  file { "$mountpoint":
    ensure => directory,
    owner => "root",
    group => "root",
    mode => 0777,
    require => File["${root}/${aws_acct}"],
  }

  # Create cache directory:
  $cache_dir = "/tmp/s3fs-cache-${title}"
  file { $cache_dir:
    ensure => directory,
    owner => "root",
    group => "root",
    mode => 0700,
  }
  
  # Do actual mount - test for existing mount with df.  Mount test
  # using df necessitates an unmount to upgrade s3fs version used for
  # actual mount.
  exec { "mount $title":
    command => "/usr/local/bin/s3fs-${s3fs::build::version} $title -o passwd_file=/usr/local/etc/s3fs-${aws_acct}.passwd -o allow_other $mountpoint -o use_cache=${cache_dir}",
    onlyif => $lsbdistid ? {
      CentOS => "/usr/bin/test -n `/bin/df $mountpoint | /usr/bin/awk '/fuse/ { print $1}'`",
      Ubuntu => "/usr/bin/test -n `/bin/df $mountpoint | /usr/bin/awk '/s3fs/ { print $1}'`",
    },
    require => [ File["$mountpoint"],
                 File["$cache_dir"],
                 Exec["install s3fs"],
                 File["/usr/local/etc/s3fs-${aws_acct}.passwd"], ],
  }

}

# Define used in anticlasses to remove s3fs configuration:
define s3fs::unmount($aws_acct, $root, $leaf) {

  $mountpoint = "${root}/${aws_acct}/${leaf}"
  
  exec { "unmount $title":
    command => "/bin/fusermount -u $mountpoint",
    unless => $lsbdistid ? {
      CentOS => "/usr/bin/test -n `/bin/df $mountpoint | /usr/bin/awk '/fuse/ { print $1}'`",
      Ubuntu => "/usr/bin/test -n `/bin/df $mountpoint | /usr/bin/awk '/s3fs/ { print $1}'`",
    }                      
  }

  # Remove mountpoint with "force" because it is a directory:
  file { "rm $mountpoint":
    path => $mountpoint,
    ensure => absent,
    backup => false,
    force => true,
    require => Exec["unmount $title"],
  }
  
}

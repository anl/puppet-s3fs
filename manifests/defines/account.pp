# Configure an AWS account for mounting S3 buckets:

# $title: Nickname for AWS account credentials
# $group: UNIX group mapped to the AWS account
# $root: Base of S3 mounts, below which accounts are grouped

define s3fs::account($group, $root) {

  # Create account group directory:
  file { "${root}/${title}":
    ensure => directory,
    owner => root,
    group => $group,
    mode => 0550,
    require => File["$root"],
  }

  # Load in identities and secrets from outside of Puppet repo; note
  # that these files must *not* contain a trailing newline.
  $aws_id = file("/srv/puppet/${title}-aws-access-key-id")
  $aws_secret = file("/srv/puppet/${title}-aws-secret-access-key")

  # Password file for mount:
  file { "/usr/local/etc/s3fs-${title}.passwd":
    content => template("s3fs/passwd.erb"),
    owner => root,
    group => root,
    mode => 0400,
  }
  
}

# Define used in anticlasses to remove AWS accounts:
define s3fs::remove_account($root) {

  # Remove group directory - "force" required because it is a directory:
  file { "rm ${root}/${title}":
    path => "${root}/${title}",
    ensure => absent,
    backup => false,
    force => true,
  }

  file { "/usr/local/etc/s3fs-${title}.passwd":
    ensure => absent,
  }
  
}

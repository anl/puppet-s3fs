# Example class configuring actual s3fs mounts on a system
class s3fs::example {

  # Create a /cloud/example directory, owned by group admin; populate
  # credential file in /usr/local/etc from credentials stored in
  # /srv/puppet:
  s3fs::account { "example":
    group => "admin",
    root => "/cloud",
  }

  # Mount S3 bucket src.example.com using the "example" credentials
  # from above, at /cloud/example/src and a cache directory in /tmp:
  s3fs::do_mount { "src.example.com":
    aws_acct => "example",
    root => "/cloud",
    leaf => "src",
  }
  
}

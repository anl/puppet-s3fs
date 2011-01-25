define s3fs::root() {
    file { $title:
        ensure => directory,
	owner => root,
	group => root,
	mode => 0555,
    }
}

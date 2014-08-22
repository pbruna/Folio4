package {"mysql-server":
	ensure => "latest",
	name => "mysql-server-5.5"
}

package {"mysql-client":
	ensure => "latest",
}

service {"mysql":
	ensure => "running",
	enable => "true",
	require => Package["mysql-server"]
}
node 'vagrant-trusty64' {
    class { 'apt': }

    package { 'software-properties-common':
        ensure => present,
    }
    
    # docker dependencies
    apt::source { 'docker':
        location => 'https://get.docker.com/ubuntu',
        release  => 'docker',
        repos    => 'main',
        key      => {
            'id'     => '36A1D7869245C8950F966E92D8576A8BA88D21E9',
            'server' => 'hkp://p80.pool.sks-keyservers.net:80'
        },
        include  => {
            'deb' => true,
        }
    }

    package { 'lxc-docker':
        ensure  => present,
        require => Apt::Source['docker'],
    }

    Apt::Source['docker'] -> Class['Apt::Update'] -> Package['lxc-docker']

    # global 
    Package['software-properties-common'] -> Apt::Ppa <| |>
}

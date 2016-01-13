# firefox is needed for GUI test of dukecon
package { 'firefox':
  ensure => 'latest',
}

# used for headless testing
package { 'xvfb':
  ensure => 'installed'
}
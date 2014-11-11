# == Class: kiosk::java
#
# Puppet module to install java modus
#
# === Authors
#
# foppe.pieters@naturalis.nl
#
# === Copyright
#
# Copyright 2014
#

class kiosk::java(
  $packages                             = ['xorg','openbox','openjdk-7-jre','p7zip-full','build-essential','plymouth-theme-solar'],
  $extractpassword                      = undef,
  $applet_name                          = undef,
  $applet_images                        = undef,
  $platform                             = undef,
  $images_path                          = undef,
  $interactive_name                     = undef,
  $dirs                                 = ['/home/kiosk/','/home/kiosk/.config','/home/kiosk/.config/openbox','/home/kiosk/.icons/','/home/kiosk/.icons/default/','/home/kiosk/.icons/default/cursors'],
)
{
  include stdlib
# install packages
  package { $packages:
    ensure                => installed
  }
# download and untar transparent cursor
  exec { 'download_transparent':
    command               => '/usr/bin/curl http://downloads.yoctoproject.org/releases/matchbox/utils/xcursor-transparent-theme-0.1.1.tar.gz -o /tmp/xcursor-transparent-theme-0.1.1.tar.gz && /bin/tar -xf /tmp/xcursor-transparent-theme-0.1.1.tar.gz -C /tmp',
    unless                => '/usr/bin/test -f /tmp/xcursor-transparent-theme-0.1.1.tar.gz',
    require               => [Package[$packages]]
  }
# configure transparent cursor
  exec {'config_transparent':
    command               => '/bin/sh configure',
    cwd                   => '/tmp/xcursor-transparent-theme-0.1.1',
    unless                => '/usr/bin/test -f /home/kiosk/.icons/default/cursors/transp',
    require               => Exec['download_transparent']
  }
# configure transparent cursor
  exec {'make_transparent':
    command               => '/usr/bin/make install-data-local DESTDIR=/home/kiosk/.icons/default CURSOR_DIR=/cursors -k',
    cwd                   => '/tmp/xcursor-transparent-theme-0.1.1/cursors',
    unless                => '/usr/bin/test -f /home/kiosk/.icons/default/cursors/transp',
    require               => Exec['config_transparent']
  }
# autoset transparent cursor
  file { '/home/kiosk/.icons/default/cursors/emptycursor':
    ensure                => present,
    mode                  => '0644',
    content               => template('kiosk/emptycursor.erb'),
    require               => Exec['make_transparent']
  }
# setup kiosk user
  user { 'kiosk':
    comment               => 'kiosk user',
    home                  => '/home/kiosk',
    ensure                => present,
    managehome            => true,
    password              => sha1('kiosk'),
  }
# startx on login
  file { '/home/kiosk/.profile':
    ensure                => present,
    mode                  => '0644',
    content               => template('kiosk/.profile.erb'),
    require               => [User['kiosk']]
  }
# autologin kiosk user
  file { '/etc/init/tty1.conf':
    ensure                => present,
    mode                  => '0644',
    content               => template('kiosk/tty1.conf.erb'),
    require               => [User['kiosk']]
  }
# autostart openbox and disable screensaver/blanking
  file { '/home/kiosk/.xinitrc':
    ensure                => present,
    mode                  => '0644',
    owner                 => 'kiosk',
    content               => template('kiosk/.xinitrc.erb'),
    require               => [User['kiosk']]
  }
# make userdirs
  file { $dirs:
    ensure                => 'directory',
    require               => User['kiosk'],
    owner                 => 'kiosk',
    group                 => 'kiosk',
    mode                  => '0644'
  }
# autostart java
  case $operatingsystem {
  ubuntu: {
  file { '/home/kiosk/.config/openbox/autostart.sh':
    ensure                => present,
    mode                  => '0644',
    content               => template('kiosk/openbox-autostart-java-linux.sh.erb'),
    require               => [File['/home/kiosk/.config/openbox']]
  }
  }
  default: {
  file { '/home/kiosk/.config/openbox/autostart.sh':
    ensure                => present,
    mode                  => '0644',
    content               => template('kiosk/openbox-autostart-java-win.sh.erb'),
    require               => [File['/home/kiosk/.config/openbox']]
    }
  }
  }
  common::directory_structure{ '/data/kiosk/${applet_name}':
    user                  => 'kiosk',
    mode                  => '0755'
  }
# download java applet
  file {"/data/kiosk/${applet_name}/${applet_name}.zip":
    source                => "puppet:///modules/kiosk/${applet_name}.zip",
    ensure                => 'present',
    mode                  => '755',
    owner                 => 'kiosk',
    group                 => 'kiosk',
    require               => Common::Directory_structure["/data/kiosk/${applet_name}"],
    notify                => Exec['java-unzip']
  }
# download protected images
  file {"/data/kiosk/${applet_name}/${applet_images}.zip":
    source                => "puppet:///modules/kiosk/${applet_images}.zip",
    ensure                => 'present',
    mode                  => '755',
    owner                 => 'kiosk',
    group                 => 'kiosk',
    require               => Common::Directory_structure["/data/kiosk/${applet_name}"],
    notify                => Exec['java-unzip-images']
  }
# unzip java applet
  exec {'java-unzip':
    command               => "/usr/bin/7z x -aoa /data/kiosk/${applet_name}/${applet_name}.zip",
    cwd                   => "/data/kiosk/${applet_name}",
    user                  => 'kiosk',
    group                 => 'kiosk',
    unless                => "/usr/bin/test -f /data/kiosk/${applet_name}/$interactive_name",
    refreshonly           => true,
    require               => [ Common::Directory_structure["/data/kiosk/${applet_name}"], File["/data/kiosk/${applet_name}/${applet_name}.zip"] ],
    notify                => [ Common::Directory_structure["/data/kiosk/${applet_name}/$platform/$images_path"] ],
  }
  common::directory_structure{ "/data/kiosk/${applet_name}/$platform/$images_path":
    user                  => 'kiosk',
    mode                  => '0755',
  }
# unzip images
  exec {"java-unzip-images":
    command               => "/usr/bin/7z x -p${extractpassword} -aoa /data/kiosk/${applet_name}/${applet_images}.zip",
    cwd                   => "/data/kiosk/${applet_name}/$platform/$images_path",
    user                  => 'kiosk',
    group                 => 'kiosk',
    unless                => "/usr/bin/test -f /data/kiosk/${applet_name}/$platform/$images_path",
    refreshonly           => true,
    require               => [ Common::Directory_structure["/data/kiosk/${applet_name}/$platform/$images_path"], File["/data/kiosk/${applet_name}/${applet_images}.zip"] ],
  }
}
